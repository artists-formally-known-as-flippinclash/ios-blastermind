//
//  AppDelegate.swift
//  Blastermind
//
//  Created by Stephen Christopher on 2015.03.05.
//  Copyright (c) 2015 Big Nerd Ranch. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let client = Server()

        client.startClient()

        let serverConnection = ServerConnection()
        serverConnection.guess([1,1,1,1], result: { (feedback) -> () in
            println("surprise")
        })

        return true
    }

}

