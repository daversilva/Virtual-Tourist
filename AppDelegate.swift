//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by David Rodrigues on 12/08/2018.
//  Copyright © 2018 David Rodrigues. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        DataController.shared.load()
        DataController.shared.applicationDocumentsDirectory()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        let vm = LocationsViewModel()
        let vc = LocationsViewController(viewModel: vm)
        window?.rootViewController = UINavigationController(rootViewController: vc)
        
        return true
    }

}
