//
//  AppDelegate.swift
//  IsolatedReactorKit
//
//  Created by wotjd on 2021/03/13.
//

import UIKit
import RxSwift
import ReactorKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let window = UIWindow()
    
    defer { self.window = window }
    
    let viewController = ViewController()
    
    window.rootViewController = viewController
    window.makeKeyAndVisible()
    
    return true
  }
}

