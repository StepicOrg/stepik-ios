//
//  Video.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Alamofire
import CoreData
import Foundation
import SwiftyJSON
import SwiftyJSON

enum VideoState {
    case online, cached
}

@objc
final class Video: NSManagedObject, JSONSerializable {
    typealias IdType = Int

    required convenience init(json: JSON) {
        self.init()
        initialize(json)
    }

    func initialize(_ json: JSON) {
        id = json["id"].intValue
        thumbnailURL = json["thumbnail"].stringValue
        status = json["status"].stringValue

        var videoURLs: [VideoURL] = []
        for urlJSON in json["urls"].arrayValue {
            videoURLs += [VideoURL(json: urlJSON)]
        }
        urls = videoURLs
    }

    func update(json: JSON) {
        initialize(json)
    }

    func equals(_ object: Any?) -> Bool {
        guard let object = object as? Video else {
            return false
        }

        if self === object { return true }
        if type(of: self) != type(of: object) { return false }

        if self.id != object.id { return false }
        if self.thumbnailURL != object.thumbnailURL { return false }
        if self.status != object.status { return false }

        if self.urls.count != object.urls.count { return false }
        for (lhsVideoURL, rhsVideoURL) in zip(self.urls, object.urls) {
            if !lhsVideoURL.equals(rhsVideoURL) {
                return false
            }
        }

        return true
    }

    static func getNearestDefault(to quality: String) -> String {
        let qualities = ["270", "360", "720", "1080"]
        var minDifference = 10000
        var res: String = "270"
        for defaultQuality in qualities {
            if abs(Int(defaultQuality)! - Int(quality)!) < minDifference {
                minDifference = abs(Int(defaultQuality)! - Int(quality)!)
                res = defaultQuality
            }
        }
        return res
    }

    func getNearestQualityToDefault(_ quality: String) -> String {
        var minDifference = 10000
        var res: String = "270"
        for url in urls {
            if abs(Int(url.quality)! - Int(quality)!) < minDifference {
                minDifference = abs(Int(url.quality)! - Int(quality)!)
                res = url.quality
            }
        }
        return res
    }

    func getUrlForQuality(_ quality: String) -> URL? {
        if self.urls.isEmpty {
            return nil
        }

        var urlToReturn: VideoURL?
        var minDifference = 10000
        for url in urls {
            if abs(Int(url.quality)! - Int(quality)!) < minDifference {
                minDifference = abs(Int(url.quality)! - Int(quality)!)
                urlToReturn = url
            }
        }

        if let url = urlToReturn {
            return URL(string: url.url)
        } else {
            return URL(string: self.urls[0].url)
        }
    }

    var state: VideoState {
        VideoStoredFileManager(fileManager: FileManager.default).getVideoStoredFile(videoID: id) != nil
            ? .cached
            : .online
    }

    static func getAllVideos() -> [Video] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        let predicate = NSPredicate(value: true)
        request.predicate = predicate
        do {
            let results = try CoreDataHelper.shared.context.fetch(request)
            return results as! [Video]
        } catch {
            print("Error while getting videos")
            return []
        }
    }
}
