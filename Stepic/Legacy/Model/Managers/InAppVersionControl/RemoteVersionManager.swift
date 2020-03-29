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
    static let shared = RemoteVersionManager()

    override private init() {}

    func checkRemoteVersionChange(
        needUpdateHandler update: @escaping (Version?) -> Void,
        error errorHandler: @escaping (Error) -> Void
    ) {
        let localVersion = self.getLocalVersion()
        self.getRemoteVersion(
            success: { remote, url in
                if self.isVersion(remote, olderThan: localVersion) {
                    if let correctUrl = URL(string: url) {
                        update(Version(version: remote, url: correctUrl))
                        return
                    }
                }
                update(nil)
            },
            error: { error in
                errorHandler(error)
            }
        )
    }

    private func getLocalVersion() -> String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    private func isVersion(_ v1: String, olderThan v2: String) -> Bool {
        v1.compare(v2, options: NSString.CompareOptions.numeric) == ComparisonResult.orderedDescending
    }

    @discardableResult
    private func getRemoteVersion(
        success: @escaping (String, String) -> Void,
        error errorHandler: @escaping (Error) -> Void
    ) -> Request {
        AlamofireDefaultSessionManager
            .shared
            .request(StepikApplicationsInfo.versionInfoURL)
            .responseSwiftyJSON { response in
                switch response.result {
                case .success(let json):
                    if let version = json["version"].string,
                       let url = json["url"].string {
                        success(version, url)
                    }
                case .failure(let error):
                    errorHandler(error)
                }
            }
    }
}
