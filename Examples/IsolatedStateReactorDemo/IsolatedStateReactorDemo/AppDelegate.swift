//
//  AppDelegate.swift
//  IsolatedStateReactorDemo
//
//  Created by wotjd on 2021/09/04.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let window = UIWindow()
    defer { self.window = window }
    
    window.rootViewController = ViewController()
    window.makeKeyAndVisible()
    
    return true
  }
}

