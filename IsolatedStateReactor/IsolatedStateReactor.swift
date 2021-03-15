//
//  IsolatedStateReactor.swift
//  IsolatedStateReactor
//
//  Created by wotjd on 2021/03/15.
//

import ReactorKit

protocol UpdateStorable {
  var updates: [PartialKeyPath<Self>] { get set }
  subscript<T>(_ keyPath: WritableKeyPath<Self, T>) -> T { get set }
}

extension UpdateStorable {
  subscript<T>(_ keyPath: WritableKeyPath<Self, T>) -> T {
    get { self[keyPath: keyPath] }
    set {
      self[keyPath: keyPath] = newValue
      self.updates.append(keyPath)
    }
  }
}

@dynamicMemberLookup
struct DynamicWritableWrapper<T> {
  var value: T
  
  init(_ value: T) {
    self.value = value
  }
  
  subscript<Member>(dynamicMember dynamicMember: WritableKeyPath<T, Member>) -> Member {
    get { self.value[keyPath: dynamicMember] }
    set { self.value[keyPath: dynamicMember] = newValue }
  }
}

extension DynamicWritableWrapper where T: UpdateStorable {
  subscript<Member>(dynamicMember dynamicMember: WritableKeyPath<T, Member>) -> Member {
    get { self.value[dynamicMember] }
    set { self.value[dynamicMember] = newValue }
  }
}

protocol IsolatedStateReactor: Reactor where State: UpdateStorable {
  typealias IsolatedState = DynamicWritableWrapper<State>
  
  func reduce(isolatedState: IsolatedState, mutation: Mutation) -> IsolatedState
  func reduce(isolatedState: inout IsolatedState, mutation: Mutation)
}

extension IsolatedStateReactor {
  func reduce(state: State, mutation: Mutation) -> State {
    self.reduce(isolatedState: .init(state), mutation: mutation).value
  }
  
  func reduce(isolatedState: IsolatedState, mutation: Mutation) -> IsolatedState {
    var isolatedState = isolatedState
    isolatedState.updates = []
    self.reduce(isolatedState: &isolatedState, mutation: mutation)
    return isolatedState
  }
  
  func reduce(isolatedState: inout IsolatedState, mutation: Mutation) { }
  
  func isolatedState<T>(_ keyPath: KeyPath<State, T>) -> Observable<T> {
    self.state
      .filter {
        $0.updates.contains(keyPath)
          // contains initial state
          || $0.updates.contains(\State.self)
      }
      .map({ $0[keyPath: keyPath] })
  }
}
