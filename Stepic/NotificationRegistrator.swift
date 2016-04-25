//
//  NotificationRegistrator.swift
//  Stepic
//
//  Created by Alexander Karpov on 21.04.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import Google


//Class for registering the remote notifications service
class NotificationRegistrator: NSObject {
    static let sharedInstance = NotificationRegistrator()
    
    private override init() {
        super.init()
    }
    
    func registerForRemoteNotifications(application: UIApplication) {
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }
    
    func getGCMRegistrationToken(deviceToken deviceToken: NSData) {
        let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
        instanceIDConfig.delegate = self
        // Start the GGLInstanceID shared instance with that config and request a registration
        // token to enable reception of notifications
        GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken,
                               kGGLInstanceIDAPNSServerTypeSandboxOption:true]
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(GGLContext.sharedInstance().configuration.gcmSenderID,
                                                                 scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
    
    var registrationOptions = [String: AnyObject]()
    
    let registrationKey = "onRegistrationCompleted"

    private func registrationHandler(registrationToken: String!, error: NSError!) {
        if (registrationToken != nil) {
            print("Registration Token: \(registrationToken)")
            let device = Device(registrationId: registrationToken, deviceDescription: "ios test device sample description")
            ApiDataDownloader.devices.create(device, success: {
                device in
                print("created device: \(device.getJSON())")
            }, error : {
                error in 
                print("error! :(")
            })
            
//            let userInfo = ["registrationToken": registrationToken]
//            NSNotificationCenter.defaultCenter().postNotificationName(self.registrationKey, object: nil, userInfo: userInfo)
        } else {
            print("Registration to GCM failed with error: \(error.localizedDescription)")
            
//            let userInfo = ["error": error.localizedDescription]
//            NSNotificationCenter.defaultCenter().postNotificationName(self.registrationKey, object: nil, userInfo: userInfo)
        }
    }    
    
    
}

extension NotificationRegistrator : GGLInstanceIDDelegate {
    func onTokenRefresh() {
        print("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(GGLContext.sharedInstance().configuration.gcmSenderID,
                                                                 scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
}
