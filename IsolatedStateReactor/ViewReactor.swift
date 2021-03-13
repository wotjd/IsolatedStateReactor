//
//  ViewReactor.swift
//  IsolatedReactorKit
//
//  Created by wotjd on 2021/03/13.
//

import ReactorKit

class ViewReactor: Reactor {
  enum Action {
    case loadName
    case loadAge
    case refresh
  }
  
  enum Mutation {
    case setName
    case setAge
    case refresh
  }
  
  struct State {
    var name = ""
    var age = 0
    
    fileprivate var currentUpdates: [PartialKeyPath<Self>] = []
    
    fileprivate subscript<T>(_ keyPath: WritableKeyPath<Self, T>) -> T {
      get { self[keyPath: keyPath] }
      set {
        self[keyPath: keyPath] = newValue
        self.currentUpdates.append(keyPath)
      }
    }
  }
  
  let initialState = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .loadName:
      return .just(.setName)
    case .loadAge:
      return .just(.setAge)
    case .refresh:
      return .just(.refresh)
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    state.currentUpdates = []
    switch mutation {
    case .setName:
      state[\.name] = self.randomString(length: 10)
    case .setAge:
      state[\.age] = (0...100).randomElement() ?? 0
    case .refresh:
      let name = state.name
      let age = state.age
      
      state[\.name] = name
      state[\.age] = age
    }
    return state
  }
  
  func isolatedState<T>(_ keyPath: KeyPath<State, T>) -> Observable<T> {
    self.state
      .filter({ $0.currentUpdates.contains(keyPath) })
      .map({ $0[keyPath: keyPath] })
  }
  
  private func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).compactMap{ _ in letters.randomElement() })
  }
}
