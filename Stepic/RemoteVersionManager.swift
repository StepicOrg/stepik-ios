//
//  RemoteVersionManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 27.04.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Alamofire
import SwiftyJSON
import UIKit

/*
 This class manages remote version change
 */
final class RemoteVersionManager: NSObject {
    override private init() {}
    static let sharedManager = RemoteVersionManager()

    private func isVersion(_ v1: String, olderThan v2: String) -> Bool {
        v1.compare(v2, options: NSString.CompareOptions.numeric) == ComparisonResult.orderedDescending
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

    private func getLocalVersion() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    private func getRemoteVersion(success: @escaping (String, String) -> Void, error errorHandler: @escaping (NSError) -> Void) -> Request {
        AlamofireDefaultSessionManager.shared.request(StepikApplicationsInfo.versionInfoURL).responseSwiftyJSON({
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
