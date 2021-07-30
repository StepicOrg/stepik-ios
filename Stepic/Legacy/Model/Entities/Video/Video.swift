import Alamofire
import CoreData
import SwiftyJSON

enum VideoState {
    case online, cached
}

@objc
final class Video: NSManagedObject, ManagedObject, JSONSerializable {
    typealias IdType = Int

    var state: VideoState {
        VideoStoredFileManager(fileManager: FileManager.default).getVideoStoredFile(videoID: id) != nil
            ? .cached
            : .online
    }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json["id"].intValue
        self.thumbnailURL = json["thumbnail"].stringValue
        self.status = json["status"].stringValue

        var videoURLs: [VideoURL] = []
        for urlJSON in json["urls"].arrayValue {
            videoURLs += [VideoURL(json: urlJSON)]
        }

        self.urls = videoURLs
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
}
