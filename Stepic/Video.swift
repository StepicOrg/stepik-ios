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
    
    private func getUrlForQuality(quality: VideoQuality) -> NSURL {
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
    
    var download : VideoDownload? = nil
    var totalProgress : Float = 0
    var isDownloading = false
    
    var storedProgress : (Float->Void)?
    var storedCompletion : (Bool->Void)?

    func store(quality: VideoQuality, progress: (Float -> Void), completion: (Bool -> Void), error errorHandler: (NSError? -> Void)) {

        storedProgress = progress
        storedCompletion = completion
        isDownloading = true
        
        let url = getUrlForQuality(quality)
                
        do {
            if let ext = url.pathExtension {
                try PathManager.sharedManager.createVideoWith(id: id, andExtension: ext)
            } else {
                print("Something went wrong in store function, no file extension in url")
                isDownloading = false
                errorHandler(nil)
                return
            }
        }
            
        catch let error as NSError {
            print(error.localizedDescription)
            isDownloading = false
            errorHandler(error)
            return
        }
        
        var videoURL = NSURL()
        
        do {
            videoURL = try PathManager.sharedManager.getVideoDirectoryURL()
        }
        catch let error as NSError {
            print(error.localizedDescription)
            isDownloading = false
            errorHandler(error)
            return
        }
        
        let ext = url.pathExtension!
        
        let download = TCBlobDownloadManager.sharedInstance.downloadFileAtURL(url, toDirectory: videoURL, withName: "\(id).\(ext)", progression: {
            prog, bytesWritten, bytesExpectedToWrite in
                self.totalProgress = prog
                self.storedProgress?(prog)
            }, completion: {
                error, location in
                self.isDownloading = false
                if error != nil {
                    self.totalProgress = 0
                    if error!.code == -999 {
                        self.storedCompletion?(false)
                    } else {
                        errorHandler(error)
                    }
                    return
                } 
                
                print("video download completed with quality -> \(quality.rawString)")
                if let fileURL = location {
                    self.managedCachedPath = fileURL.lastPathComponent!
                    self.cachedQuality = quality
                    self.totalProgress = 1
                    CoreDataHelper.instance.save()
                } else {
                    self.totalProgress = 0
                    errorHandler(nil)
                    return
                }
                self.storedCompletion?(true)
        })
        self.download = VideoDownload(download: download, videoId: id)
    }
    
    func cancelStore() -> Bool {
//        print("Entered video cancelStore")
        if let d = download?.download {
            d.downloadTask.cancel()
            download = nil
            self.managedCachedPath = nil
            self.cachedQuality = nil
            self.totalProgress = 0
            CoreDataHelper.instance.save()
//            print("Finished video cancelStore")
            self.isDownloading = false
            return true
        } else {
            return false
        }
    }
    
    func removeFromStore() -> Bool {
        self.isDownloading = false
        if isCached {
            do {
//                print("\nremoving file at \(cachedPath!)\n")
                try PathManager.sharedManager.deleteVideoFileAtPath(PathManager.sharedManager.getPathForStoredVideoWithName(cachedPath!))
//                print("file successfully removed")
                self.managedCachedPath = nil
                CoreDataHelper.instance.save()
                download = nil
                self.totalProgress = 0
                return true
            }
            catch let error as NSError {
                print(error.localizedFailureReason)
                print(error.code)
                print(error.localizedDescription)
                if error.code == 4 {
                    self.totalProgress = 0
                    return true
                } else {
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
            print("Error while getting courses")
            return []
            //            throw FetchError.RequestExecution
        }
    }
    
}
