//
//  ViewReactor.swift
//  IsolatedStateReactorDemo
//
//  Created by wotjd on 2021/09/04.
//

import ReactorKit
import IsolatedStateReactor

class ViewReactor: IsolatedStateReactor {
  enum Action {
    case loadName
    case loadAge
    case refresh
  }
  
  enum Mutation {
    case setName(String)
    case setAge(Int)
    case refresh
  }
  
  struct State: UpdateStorable {
    var name = ""
    var age = 0
    
    var updates: [PartialKeyPath<Self>] = [\State.self]
  }
  
  let initialState = State()
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .loadName:
      return .just(.setName(self.randomString(length: 10)))
    case .loadAge:
      return .just(.setAge((0...100).randomElement() ?? 0))
    case .refresh:
      return .just(.refresh)
    }
  }
  
  func reduce(isolatedState: inout IsolatedState, mutation: Mutation) {
    switch mutation {
    case let .setName(name):
      isolatedState.name = name
    case let .setAge(age):
      isolatedState.age = age
    case .refresh:
      let name = isolatedState.name
      let age = isolatedState.age
      
      isolatedState.name = name
      isolatedState.age = age
    }
  }
  /*
  func reduce(isolatedState: IsolatedState, mutation: Mutation) -> IsolatedState {
    var isolatedState = isolatedState
    switch mutation {
    case let .setName(name):
      isolatedState.name = name
    case let .setAge(age):
      isolatedState.age = age
    case .refresh:
      let name = isolatedState.name
      let age = isolatedState.age
      
      isolatedState.name = name
      isolatedState.age = age
    }
    return isolatedState
  }
  */
  
  private func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).compactMap{ _ in letters.randomElement() })
  }
}
