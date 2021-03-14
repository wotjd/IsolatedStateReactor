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

protocol IsolatedStateReactor: Reactor where State: UpdateStorable {
  typealias IsolatedState = State
  
  func reduce(isolatedState: inout IsolatedState, mutation: Mutation)
}

extension IsolatedStateReactor {
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    state.updates = []
    self.reduce(isolatedState: &state, mutation: mutation)
    return state
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
