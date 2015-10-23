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
        var urlToReturn : VideoURL? = nil
        var minDifference = 10000
        for url in urls {
            if abs(Int(url.quality)! - quality.rawValue) <  minDifference {
                minDifference = abs(Int(url.quality)! - quality.rawValue)
                urlToReturn = url
            }
        }
        
        if let url = urlToReturn {
            return NSURL(string: url.url)!
        } else {
            return NSURL(string: urls[0].url)!
        }
    }
    
    var download : TCBlobDownload? = nil
    
    func store(quality: VideoQuality, progress: (Float -> Void), completion: (Void->Void)) {
        let url = getUrlForQuality(quality)
                
        do {
            if let ext = url.pathExtension {
                try PathManager.sharedManager.createVideoWith(id: id, andExtension: ext)
            } else {
                print("Something went wrong in store function, no file extension in url")
            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        var videoURL = NSURL()
        
        do {
            videoURL = try PathManager.sharedManager.getVideoDirectoryURL()
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        let ext = url.pathExtension!
        
        download = TCBlobDownloadManager.sharedInstance.downloadFileAtURL(url, toDirectory: videoURL, withName: "\(id).\(ext)", progression: {
            prog, bytesWritten, bytesExpectedToWrite in
                progress(prog)
            }, completion: 
            {
                error, location in
                if error != nil {
                    print(error!.localizedDescription)
                    print("error while downloading")
                    return
                } 
                
                print("download completed")
                if let fileURL = location {
                    self.managedCachedPath = fileURL.lastPathComponent!
                    CoreDataHelper.instance.save()
                }
                completion()
        })
    }
    
    func cancelStore() {
        if let d = download {
            d.downloadTask.cancel()
        }
    }
    
    func removeFromStore() -> Bool {
        if isCached {
            do {
                print("\nremoving file at \(cachedPath!)\n")
                try PathManager.sharedManager.deleteVideoFileAtPath(PathManager.sharedManager.getPathForStoredVideoWithName(cachedPath!))
                print("file successfully removed")
                self.managedCachedPath = nil
                CoreDataHelper.instance.save()
                return true
            }
            catch let error as NSError {
                print(error.localizedFailureReason)
                print(error.code)
                print(error.localizedDescription)
                return false
            }
        } else {
            return false
        }
    }
}
