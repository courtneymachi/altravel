//
//  AppDelegate.swift
//  Altravel
//
//  Created by courtney machi on 10/31/15.
//  Copyright © 2015 courtney machi. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import FBSDKLoginKit
import ParseFacebookUtilsV4

import Fabric
import Crashlytics

import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Parse.setApplicationId("cRNvN1a8JbJuRJumjVsdGzEndrn8ytYV2rUcnBSv", clientKey: "lVWdcXXkXn34MLvMNN4Ql7BU7eZoVfs2G39rnmVf")
    
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions);
        
        // Register Parse subclasses
        UserProperty.registerSubclass()
        Trip.registerSubclass()
        TripStep.registerSubclass()
        
        // set Parse ACL

        PFUser.enableAutomaticUser()
        
        let defaultACL = PFACL.init()
        defaultACL.publicReadAccess = false
        defaultACL.publicWriteAccess = false
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser: true)
        
        // Facebook
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Fabric
        Fabric.with([Crashlytics.self, Answers.self])
        
        // Google Maps
        GMSServices.provideAPIKey("AIzaSyA1tR4TwwuHmTnRY2TgpZwfqkDIla_5ugM")
        
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        FBSDKAppEvents.activateApp()
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        
    
    }


}

