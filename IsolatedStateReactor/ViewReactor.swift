//
//  ViewReactor.swift
//  IsolatedReactorKit
//
//  Created by wotjd on 2021/03/13.
//

import ReactorKit

class ViewReactor: IsolatedStateReactor {
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
  
  struct State: UpdateStorable {
    var name = ""
    var age = 0
    
    var updates: [PartialKeyPath<Self>] = [\State.self]
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
  
  func reduce(isolatedState: inout IsolatedState, mutation: Mutation) {
    switch mutation {
    case .setName:
      isolatedState[\.name] = self.randomString(length: 10)
    case .setAge:
      isolatedState[\.age] = (0...100).randomElement() ?? 0
    case .refresh:
      let name = isolatedState.name
      let age = isolatedState.age
      
      isolatedState[\.name] = name
      isolatedState[\.age] = age
    }
  }
  
  private func randomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).compactMap{ _ in letters.randomElement() })
  }
}
