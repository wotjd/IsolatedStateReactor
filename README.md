# IsolatedStateReactor
A simple isolated state implementation for ReactorKit

## Previously,
`distinctUntilChanged` operator follows state observable and this produces quiet complicated code. 

for example,
```swift
// in bind(reactor:)
reactor.state.map(\.someBoolState)
  .distinctUntilChanged()
  ...
// in reactor.mutate(action:)
// to avoid skipping event by distinctUntilChanged
return Observable.of(true, false).map(Mutation.updateBoolState)
```
## `isolatedState`
to solve this, I made `isolatedState`
```swift
// usage
reactor.isolatedState(\.boolProperty)
  // work properly without distinctUntilChanged()
  .subscribe(...)
  
// implementation
class ViewReactor: Reactor {
  enum Action { ... }
  enum Mutation { ... }
  // State should provide currentUpdates stores keyPath array to know which property is updated by mutation
  struct State {
    var boolProperty = false
    
    var currentUpdates: [PartialKeyPath<Self>] = []
    subscript<T>(_ keyPath: WritableKeyPath<Self, T>) -> T {
      get { self[keyPath: keyPath] }
      set {
        self[keyPath: keyPath] = newValue
        self.currentUpdates.append(keyPath)
      }
    }
  }

  func isolatedState<T>(_ keyPath: KeyPath<State, T>) -> Observable<T> {
    self.state
      .filter({ $0.currentUpdates.contains(keyPath) })
      .map({ $0[keyPath: keyPath] })
  }
  
  func mutate(action: Action) -> Observable<Mutation> { ... }
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    // reset 
    state.currentUpdates = []
    switch mutation {
    case let .updateBoolProperty(bool):
      // currently, this seems like tricky
      state[\.boolProperty] = bool
    }
  }
```
