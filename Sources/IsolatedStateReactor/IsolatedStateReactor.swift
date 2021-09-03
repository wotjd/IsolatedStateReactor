import ReactorKit

public protocol UpdateStorable {
  var updates: [PartialKeyPath<Self>] { get set }
  subscript<T>(_ keyPath: WritableKeyPath<Self, T>) -> T { get set }
}

public extension UpdateStorable {
  subscript<T>(_ keyPath: WritableKeyPath<Self, T>) -> T {
    get { self[keyPath: keyPath] }
    set {
      self[keyPath: keyPath] = newValue
      self.updates.append(keyPath)
    }
  }
}

@dynamicMemberLookup
public struct DynamicWritableWrapper<T> {
  var value: T
  
  init(_ value: T) {
    self.value = value
  }
  
  subscript<Member>(dynamicMember dynamicMember: WritableKeyPath<T, Member>) -> Member {
    get { self.value[keyPath: dynamicMember] }
    set { self.value[keyPath: dynamicMember] = newValue }
  }
}

public extension DynamicWritableWrapper where T: UpdateStorable {
  subscript<Member>(dynamicMember dynamicMember: WritableKeyPath<T, Member>) -> Member {
    get { self.value[dynamicMember] }
    set { self.value[dynamicMember] = newValue }
  }
}

// TODO: Add ReferenceWritableWrapper for class type State

public protocol IsolatedStateReactor: Reactor where State: UpdateStorable {
  typealias IsolatedState = DynamicWritableWrapper<State>
  
  func reduce(isolatedState: IsolatedState, mutation: Mutation) -> IsolatedState
  func reduce(isolatedState: inout IsolatedState, mutation: Mutation)
}

public extension IsolatedStateReactor {
  func reduce(state: State, mutation: Mutation) -> State {
    var isolatedState = IsolatedState(state)
    isolatedState.updates = []
    return self.reduce(isolatedState: isolatedState, mutation: mutation).value
  }
  
  func reduce(isolatedState: IsolatedState, mutation: Mutation) -> IsolatedState {
    var isolatedState = isolatedState
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
