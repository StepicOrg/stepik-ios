//
//  Video.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON
import Alamofire
import SwiftyJSON

enum VideoState {
    case online, downloading, cached
}

class Video: NSManagedObject, JSONInitializable {

    typealias idType = Int
        
    convenience required init(json: JSON){
        self.init()
        initialize(json)
    }
    
    func initialize(_ json: JSON) {
        id = json["id"].intValue
        thumbnailURL = json["thumbnail"].stringValue
        status = json["status"].stringValue
        
        var videoURLs : [VideoURL] = []
        for urlJSON in json["urls"].arrayValue {
            videoURLs += [VideoURL(json: urlJSON)]
        }
        urls = videoURLs
    }
    
    func update(json: JSON) {
        initialize(json)
    }
    
    func hasEqualId(json: JSON) -> Bool {
        return id == json["id"].intValue
    }
    
    static func getNearestDefault(to quality: String) -> String {
        let qualities = ["270", "360", "720", "1080"]
        var minDifference = 10000
        var res : String = "270"
        for defaultQuality in qualities {
            if abs(Int(defaultQuality)! - Int(quality)!) <  minDifference {
                minDifference = abs(Int(defaultQuality)! - Int(quality)!)
                res = defaultQuality
            }
        }
        return res
    }
    
    func getNearestQualityToDefault(_ quality: String) -> String {
        var minDifference = 10000
        var res : String = "270"
        for url in urls {
            if abs(Int(url.quality)! - Int(quality)!) <  minDifference {
                minDifference = abs(Int(url.quality)! - Int(quality)!)
                res = url.quality
            }
        }
        return res
    }
    
    func getUrlForQuality(_ quality: String) -> URL {
        var urlToReturn : VideoURL? = nil
        var minDifference = 10000
        for url in urls {
            if abs(Int(url.quality)! - Int(quality)!) <  minDifference {
                minDifference = abs(Int(url.quality)! - Int(quality)!)
                urlToReturn = url
            }
        }
        
        if let url = urlToReturn {
//            print("chose \(url.quality)")
            return URL(string: url.url)!
        } else {
            return URL(string: urls[0].url)!
        }
    }
    
    var _state : VideoState?
    
    var state : VideoState! {
        get {
            if let s = _state {
                return s
            } else {
                if PathManager.sharedManager.doesExistVideoWith(id: id) {
                    if self.cachedQuality != nil && self.cachedQuality != "0" {
                        _state = .cached
                    } else {
                        if self.cachedQuality != nil {
                            self.cachedQuality = nil
                            CoreDataHelper.instance.save()
                        }
                        do { 
                            let path = try PathManager.sharedManager.getPathForStoredVideoWithName(self.name)
                            try PathManager.sharedManager.deleteVideoFileAtPath(path)
                        } 
                        catch {
                            print("error while deleting video")
                        }
                        _state = .online
                    }
                } else {
                    _state = .online
                }

                return _state!
            }
        }
        set(value) {
            _state = value
        }
    }
    
    var download : TCBlobDownload? = nil
    var totalProgress : Float = 0
    
    var downloadDelegate : VideoDownloadDelegate? = nil
    var loadingQuality : String?
    
    var storedProgress : ((Float)->Void)?
    var storedCompletion : ((Bool)->Void)?
    var storedErrorHandler : ((NSError?) -> Void)?
    func store(_ quality: String, progress: @escaping ((Float) -> Void), completion: @escaping ((Bool) -> Void), error errorHandler: @escaping ((NSError?) -> Void)) {

        print("storing video with quality \(quality)")
        loadingQuality = getNearestQualityToDefault(quality)
        storedProgress = progress
        storedCompletion = completion
        storedErrorHandler = errorHandler
        state = .downloading
        
        let url = getUrlForQuality(quality)
        let ext = url.pathExtension 

        do {
            try PathManager.sharedManager.createVideoWith(id: id, andExtension: ext)
        }
        catch let error as NSError {
            print(error.localizedDescription)
            state = .online
            errorHandler(error)
            return
        }
        
        var videoURLOptional : URL?
        
        do {
            videoURLOptional = try PathManager.sharedManager.getVideoDirectoryURL()
        }
        catch let error as NSError {
            print(error.localizedDescription)
            state = .online
            errorHandler(error)
            return
        }
        
        guard let videoURL = videoURLOptional else {
            errorHandler(NSError())
        }
        
        let manager = TCBlobDownloadManager(taskIdentifier: name)
        download = manager.downloadFileAtURL(url, toDirectory: videoURL, withName: name, progression: {
            prog, bytesWritten, bytesExpectedToWrite in
                self.downloadingSize = bytesExpectedToWrite
                self.totalProgress = prog
                self.storedProgress?(prog)
            }, completion: {
                error, location in
                if error != nil {
                    self.state = .online
                    do {
                        try PathManager.sharedManager.deleteVideoFileAtPath(PathManager.sharedManager.getPathForStoredVideoWithName(self.name))
                    }
                    catch let error as NSError {
                        if error.code != 4 {
                            print("strange error deleting videos!")
                            print(error.localizedFailureReason ?? "")
                            print(error.code)
                            print(error.localizedDescription)
                        }
                    }

                    self.totalProgress = 0
                    
                    switch error!.code {
                    case -999: 
                        self.cachedQuality = nil                    
                        CoreDataHelper.instance.save()
                        self.downloadDelegate?.didDownload(self, cancelled: true)
                        self.storedCompletion?(false)
                        break
                    case -1009, -1005:
                        self.cachedQuality = nil                    
                        CoreDataHelper.instance.save()
                        CacheManager.sharedManager.connectionCancelled += [self]
                        self.storedCompletion?(false)
                        self.downloadDelegate?.didDownload(self, cancelled: true)
                        break
                    default:
                        self.cachedQuality = nil
                        CoreDataHelper.instance.save()
                        self.storedErrorHandler?(error)
                        self.downloadDelegate?.didGetError(self)
                    }
                    return
                } 
                
                print("video download completed with quality -> \(quality)")
                if location != nil {
                    self.state = .cached
                    self.cachedQuality = self.loadingQuality
                    self.totalProgress = 1
                    CoreDataHelper.instance.save()
                } else {
                    self.state = .online
                    self.cachedQuality = nil
                    CoreDataHelper.instance.save()
                    self.totalProgress = 0
                    self.downloadDelegate?.didGetError(self)
                    errorHandler(nil)
                    return
                }
                self.storedCompletion?(true)
                self.downloadDelegate?.didDownload(self, cancelled: false)
        })
        print("started download of \(name)")
//        self.download = VideoDownload(download: download, videoId: id)
    }
    
    func cancelStore() -> Bool {
        print("Entered video cancelStore of \(name)")
        if let d = download {
            d.downloadTask.cancel()
            download = nil
            do {
                try PathManager.sharedManager.deleteVideoFileAtPath(PathManager.sharedManager.getPathForStoredVideoWithName(name))
            }
            catch let error as NSError {
                if error.code == 4 {
                    print("Video not found")
                    self.cachedQuality = nil
                    CoreDataHelper.instance.save()
                    self.totalProgress = 0
                    return true
                } else {
                    print("strange error deleting videos!")
                    print(error.localizedFailureReason ?? "")
                    print(error.code)
                    print(error.localizedDescription)
                    return false
                }
            }

            self.cachedQuality = nil
            self.totalProgress = 0
            CoreDataHelper.instance.save()
//            print("Finished video cancelStore")
            self.state = .online
            return true
        } else {
            return false
        }
    }
    
    var name : String {
        return "\(id).mp4"
    }
    
    func removeFromStore() -> Bool {
        if self.state == .cached {
            do {
//                print("\nremoving file at \(cachedPath!)\n")
                try PathManager.sharedManager.deleteVideoFileAtPath(PathManager.sharedManager.getPathForStoredVideoWithName(name))
//                print("file successfully removed")
//                self.managedCachedPath = nil
                self.cachedQuality = nil
                CoreDataHelper.instance.save()
                download = nil
                self.totalProgress = 0
                self.state = .online
                return true
            }
                
            catch let error as NSError {
                if error.code == 4 {
                    print("Video not found")
//                    self.managedCachedPath = nil
                    self.cachedQuality = nil
                    CoreDataHelper.instance.save()
                    self.totalProgress = 0
                    self.state = .online
                    return true
                } else {
                    print("strange error deleting videos!")
                    print(error.localizedFailureReason ?? "")
                    print(error.code)
                    print(error.localizedDescription)
                    return false
                }
            }
        } else {
            return false
        }
    }
    
    class func getAllVideos() -> [Video] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Video")
        let predicate = NSPredicate(value: true)
        request.predicate = predicate
        do {
            let results = try CoreDataHelper.instance.context.fetch(request)
            return results as! [Video]
        }
        catch {
            print("Error while getting videos")
            return []
            //            throw FetchError.RequestExecution
        }
    }
    
    var downloadingSize : Int64? {
        didSet {
            if let s = downloadingSize {
                if let handler = sizeHandler {
                    handler(s)
                    sizeHandler = nil
                }
            }
        }
    }
    
    fileprivate func getOnlineSizeForCurrentState(_ completion: ((Int64) -> Void)) {
        var quality : String
        if state == .online {
            quality = VideosInfo.downloadingVideoQuality
        } else {
            quality = loadingQuality!
        }
        let url = getUrlForQuality(quality)
        
        Alamofire.request(url, method: .head).responseSwiftyJSON({
            response in
            
            var error = response.result.error
            var json : JSON = [:]
            if response.result.value == nil {
                if error == nil {
                    error = NSError()
                }
            } else {
                json = response.result.value!
            }
//            let response = response.response
            
            print("size json")
            print(json)
        })
    }
    
    fileprivate func getStoredSize(_ completion: ((Int64)->Void)) {        
        do {
            let filePath = try PathManager.sharedManager.getPathForStoredVideoWithName(name)

            let attr : NSDictionary? = try FileManager.default.attributesOfItem(atPath: filePath) as? NSDictionary
            
            if let _attr = attr {
                completion(Int64(_attr.fileSize()));
            }
        } catch {
            //nothing
        }
    }
    
    var sizeHandler : ((Int64) -> Void)?
    
    func getSize(_ completion: @escaping ((Int64) -> Void)) {
        if state == .online {
            getOnlineSizeForCurrentState({
                size in
                completion(size)
            })
        }
        if state == .downloading {
            if let size = downloadingSize {
                completion(size)
            } else {
                sizeHandler = completion
            }
        }
        
        if state == .cached {
            getStoredSize({
                size in
                completion(size)
            })
        }
    }
    
}
