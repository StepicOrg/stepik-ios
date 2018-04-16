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
    fileprivate override init() {}
    static let sharedManager = RemoteVersionManager()

    fileprivate func isVersion(_ v1: String, olderThan v2: String) -> Bool {
        return v1.compare(v2, options: NSString.CompareOptions.numeric) == ComparisonResult.orderedDescending
    }

    func checkRemoteVersionChange(needUpdateHandler update: @escaping (Version?) -> Void, error errorHandler: @escaping (NSError) -> Void) {
        let local = getLocalVersion()
        _ = getRemoteVersion(
            success: {
                remote, url in
                if self.isVersion(remote, olderThan: local) {
                    if let correctUrl = URL(string: url) {
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

    fileprivate func getLocalVersion() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    fileprivate func getRemoteVersion(success: @escaping (String, String) -> Void, error errorHandler: @escaping (NSError) -> Void) -> Request {
        return AlamofireDefaultSessionManager.shared.request(StepicApplicationsInfo.versionInfoURL).responseSwiftyJSON({
            response in

            var error = response.result.error
            var json: JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
                json = response.result.value!
            }
//            let response = response.response

            if let e = error as NSError? {
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
