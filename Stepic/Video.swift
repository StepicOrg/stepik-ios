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
    case Online, Downloading, Cached
}

class Video: NSManagedObject, JSONInitializable {

// Insert code here to add functionality to your managed object subclass
        
    convenience required init(json: JSON){
        self.init()
        initialize(json)
    }
    
    func initialize(json: JSON) {
        id = json["id"].intValue
        thumbnailURL = json["thumbnail"].stringValue
        status = json["status"].stringValue
        
        var videoURLs : [VideoURL] = []
        for urlJSON in json["urls"].arrayValue {
            videoURLs += [VideoURL(json: urlJSON)]
        }
        urls = videoURLs
    }
    
    func update(json json: JSON) {
        initialize(json)
    }
    
    func getUrlForQuality(quality: VideoQuality) -> NSURL {
//        print("needed quality \(quality.rawString)")
        var urlToReturn : VideoURL? = nil
        var minDifference = 10000
        for url in urls {
//            print("has quality \(url.quality)")
            if abs(Int(url.quality)! - quality.rawValue) <  minDifference {
                minDifference = abs(Int(url.quality)! - quality.rawValue)
                urlToReturn = url
            }
        }
        
        if let url = urlToReturn {
//            print("chose \(url.quality)")
            return NSURL(string: url.url)!
        } else {
            return NSURL(string: urls[0].url)!
        }
    }
    
    var _state : VideoState?
    
    var state : VideoState! {
        get {
            if let s = _state {
                return s
            } else {
                if PathManager.sharedManager.doesExistVideoWith(id: id) {
                    _state = .Cached
                } else {
                    _state = .Online
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
    var loadingQuality : VideoQuality?
    
    var storedProgress : (Float->Void)?
    var storedCompletion : (Bool->Void)?
    var storedErrorHandler : (NSError? -> Void)?
    func store(quality: VideoQuality, progress: (Float -> Void), completion: (Bool -> Void), error errorHandler: (NSError? -> Void)) {

        loadingQuality = quality
        storedProgress = progress
        storedCompletion = completion
        storedErrorHandler = errorHandler
        state = .Downloading
        
        let url = getUrlForQuality(quality)
                
        do {
            if let ext = url.pathExtension {
                try PathManager.sharedManager.createVideoWith(id: id, andExtension: ext)
            } else {
                print("Something went wrong in store function, no file extension in url")
                state = .Online
                errorHandler(nil)
                return
            }
        }
            
        catch let error as NSError {
            print(error.localizedDescription)
            state = .Online
            errorHandler(error)
            return
        }
        
        var videoURL = NSURL()
        
        do {
            videoURL = try PathManager.sharedManager.getVideoDirectoryURL()
        }
        catch let error as NSError {
            print(error.localizedDescription)
            state = .Online
            errorHandler(error)
            return
        }
        
        let ext = url.pathExtension!
        
        download = TCBlobDownloadManager.sharedInstance.downloadFileAtURL(url, toDirectory: videoURL, withName: name, progression: {
            prog, bytesWritten, bytesExpectedToWrite in
                self.downloadingSize = bytesExpectedToWrite
                self.totalProgress = prog
                self.storedProgress?(prog)
            }, completion: {
                error, location in
                if error != nil {
                    self.state = .Online
                    do {
                        try PathManager.sharedManager.deleteVideoFileAtPath(PathManager.sharedManager.getPathForStoredVideoWithName(self.name))
                    }
                    catch let error as NSError {
                        if error.code != 4 {
                            print("strange error deleting videos!")
                            print(error.localizedFailureReason)
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
                
                print("video download completed with quality -> \(quality.rawString)")
                if let fileURL = location {
//                    self.managedCachedPath = fileURL.lastPathComponent!
                    self.state = .Cached
                    self.cachedQuality = quality
                    self.totalProgress = 1
                    CoreDataHelper.instance.save()
                } else {
//                    self.managedCachedPath = nil
                    self.state = .Online
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
//                    self.managedCachedPath = nil
                    self.cachedQuality = nil
                    CoreDataHelper.instance.save()
                    self.totalProgress = 0
                    return true
                } else {
                    print("strange error deleting videos!")
                    print(error.localizedFailureReason)
                    print(error.code)
                    print(error.localizedDescription)
                    return false
                }
            }

//            self.managedCachedPath = nil
            self.cachedQuality = nil
            self.totalProgress = 0
            CoreDataHelper.instance.save()
//            print("Finished video cancelStore")
            self.state = .Online
            return true
        } else {
            return false
        }
    }
    
    var name : String {
        return "\(id).mp4"
    }
    
    func removeFromStore() -> Bool {
        if self.state == .Cached {
            do {
//                print("\nremoving file at \(cachedPath!)\n")
                try PathManager.sharedManager.deleteVideoFileAtPath(PathManager.sharedManager.getPathForStoredVideoWithName(name))
//                print("file successfully removed")
//                self.managedCachedPath = nil
                self.cachedQuality = nil
                CoreDataHelper.instance.save()
                download = nil
                self.totalProgress = 0
                self.state = .Online
                return true
            }
                
            catch let error as NSError {
                if error.code == 4 {
                    print("Video not found")
//                    self.managedCachedPath = nil
                    self.cachedQuality = nil
                    CoreDataHelper.instance.save()
                    self.totalProgress = 0
                    self.state = .Online
                    return true
                } else {
                    print("strange error deleting videos!")
                    print(error.localizedFailureReason)
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
        let request = NSFetchRequest(entityName: "Video")
        let predicate = NSPredicate(value: true)
        request.predicate = predicate
        do {
            let results = try CoreDataHelper.instance.context.executeFetchRequest(request)
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
    
    private func getOnlineSizeForCurrentState(completion: (Int64 -> Void)) {
        var quality : VideoQuality!
        if state == .Online {
            quality = VideosInfo.videoQuality
        } else {
            quality = loadingQuality!
        }
        let url = getUrlForQuality(quality)
        
        Alamofire.request(.HEAD, url).responseSwiftyJSON(completionHandler: {
            _, _, json, error in 
            print("size json")
            print(json)
        })
    }
    
    private func getStoredSize(completion: (Int64->Void)) {        
        do {
            let filePath = try PathManager.sharedManager.getPathForStoredVideoWithName(name)

            let attr : NSDictionary? = try NSFileManager.defaultManager().attributesOfItemAtPath(filePath)
            
            if let _attr = attr {
                completion(Int64(_attr.fileSize()));
            }
        } catch {
            //nothing
        }
    }
    
    var sizeHandler : (Int64 -> Void)?
    
    func getSize(completion: (Int64 -> Void)) {
        if state == .Online {
            getOnlineSizeForCurrentState({
                size in
                completion(size)
            })
        }
        if state == .Downloading {
            if let size = downloadingSize {
                completion(size)
            } else {
                sizeHandler = completion
            }
        }
        
        if state == .Cached {
            getStoredSize({
                size in
                completion(size)
            })
        }
    }
    
}
