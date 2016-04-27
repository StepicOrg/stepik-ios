//
//  RemoteVersionManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 27.04.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

/*
 This class manages remote version change
 */
class RemoteVersionManager: NSObject {
    private override init() {}
    static let sharedManager = RemoteVersionManager()
    
    private func isVersion(v1: String, olderThan v2: String) -> Bool {
        return v1.compare(v2, options: NSStringCompareOptions.NumericSearch) == NSComparisonResult.OrderedDescending
    }
    
    func checkRemoteVersionChange(needUpdateHandler update: Version? -> Void, error errorHandler: NSError -> Void) {
        let local = getLocalVersion()
        getRemoteVersion(
            success: {
                remote, url in
                print("remote: \(remote)\nlocal: \(local)")
                if self.isVersion(remote, olderThan: local) {
                    if let correctUrl = NSURL(string: url) {
                        update(Version(version: remote, url: correctUrl))
                        return
                    }
                }
                update(nil)
                return
            }, 
            error: {
                error in
                errorHandler(error)
        })
    }
    
    private func getLocalVersion() -> String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
    }
    
    private func getRemoteVersion(success success: (String, String) -> Void, error errorHandler: NSError -> Void) -> Request {
        return Alamofire.request(.GET, StepicApplicationsInfo.versionInfoURL).responseSwiftyJSON({ 
            _, _, json, error in
            if let e = error as? NSError {
                errorHandler(e)
                return
            }
            
            if let version = json["version"].string,
            let url = json["url"].string {
                success(version, url)
            }
        })
    }
}
