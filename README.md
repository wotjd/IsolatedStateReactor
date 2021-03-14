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
class ViewReactor: IsolatedStateReactor {
  enum Action { ... }
  enum Mutation { ... }
  // State should provide currentUpdates stores keyPath array to know which property is updated by mutation
  struct State: UpdateStorable {
    var boolProperty = false
    
    var currentUpdates: [PartialKeyPath<Self>] = [\State.self]
  }

  func mutate(action: Action) -> Observable<Mutation> { ... }
  func reduce(isolatedState: inout IsolatedState, mutation: Mutation) {
    switch mutation {
    case let .updateBoolProperty(bool):
      // this might seem like pretty tricky, but there's no other way currently.
      state[\.boolProperty] = bool
    }
  }
}
```
