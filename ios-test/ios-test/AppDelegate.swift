//
//  AppDelegate.swift
//  ios-test
//
//  Created by Lucas Nahuel Giacche on 14/01/2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    private func application(application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
      return true
    }

    private func application(application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
      return true
    }
}

