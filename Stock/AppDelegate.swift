//
//  AppDelegate.swift
//  Stock
//
//  Created by Andy Fang on 12/27/19.
//  Copyright © 2019 Andy Fang. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions
    launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    configureAppearance()
    
    return true
  }
  
  func configureAppearance() {
    UINavigationBar.appearance().barTintColor = UIColor(red:0.21, green:0.44, blue:0.58, alpha:1.0)
    UINavigationBar.appearance().tintColor = .white
    UITabBar.appearance().backgroundColor = .white
  }
}
