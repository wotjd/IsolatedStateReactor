//
//  ViewController.swift
//  IsolatedStateReactorDemo
//
//  Created by wotjd on 2021/09/04.
//

import UIKit
import ReactorKit

class ViewController: UIViewController, ReactorKit.View {
  var disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    self.reactor = ViewReactor()
    
    self.reactor?.action.onNext(.loadName)
    self.reactor?.action.onNext(.loadAge)
    DispatchQueue.main.asyncAfter(
      deadline: .now() + 1,
      execute: { self.reactor?.action.onNext(.refresh) }
    )
  }
  
  func bind(reactor: ViewReactor) {
    reactor.isolatedState(\.name)
      .subscribe(onNext: {
        print("name updated from isolatedState - \($0)")
      })
      .disposed(by: self.disposeBag)
    
    reactor.isolatedState(\.age)
      .subscribe(onNext: {
        print("age updated from isolatedState - \($0)")
      })
      .disposed(by: self.disposeBag)
    
    // compare to state, state + distinctUntilChange
    /*
    reactor.state.map(\.name)
//      .distinctUntilChanged()
      .subscribe(onNext: {
        print("name updated from state - \($0)")
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.map(\.age)
//      .distinctUntilChanged()
      .subscribe(onNext: {
        print("age updated from state - \($0)")
      })
      .disposed(by: self.disposeBag)
    */
  }
}
