//
//  AppDelegate.swift
//  FireNote
//
//  Created by Denis Kovalev on 25.05.2020.
//  Copyright © 2020 Denis Kovalev. All rights reserved.
//

import Firebase
import FirebaseUI
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: RootWindow?
    lazy var session: Session = Session(apiManager: APIManager(), dataManager: DataManager(), defaultStorage: DefaultStorage())

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        FirebaseApp.configure()

        window = RootWindow()
        window?.session = session

        window?.makeKeyAndVisible()
        window?.start(nil)
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        let sourceApplication = options[.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
}
