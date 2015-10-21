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

enum VideoQuality : Int {
    case Low = 270, Medium = 360, High = 720, VeryHigh = 1080
    init(quality: Int) {
        if quality > High.rawValue {
            self = .VeryHigh
            return
        } 
        if quality > Medium.rawValue {
            self = .High
            return
        }
        if quality > Low.rawValue {
            self = .Medium
            return
        }
        self = .Low
    }
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
    
    private func getUrlForQuality(quality: VideoQuality) -> NSURL {
        //TODO : Now it's just the first url
        return NSURL(string: urls[0].url)!
    }
    
    private func getFilePath() -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        let paths = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
//        if let path = paths.first {
//            let videosPath = path.URLByAppendingPathComponent("Videos", isDirectory: true)
//            return videosPath
            return paths.first!
//        }
//        return nil
    }
    
    var download : TCBlobDownload? = nil
    
    func store(quality: VideoQuality, progress: (Float -> Void), completion: (Void->Void)) {
        let url = getUrlForQuality(quality)
        let path = getFilePath()
//        print(path)
        let ext = url.pathExtension!
        let filePath = path.URLByAppendingPathComponent("\(id).\(ext)", isDirectory: false)
//        var isDir : ObjCBool = false
//        
////        if !NSFileManager.defaultManager().fileExistsAtPath("\(path!)", isDirectory: &isDir) {
////            do { 
////                try NSFileManager.defaultManager().createDirectoryAtPath("\(path!)", withIntermediateDirectories: true, attributes: nil)
////            } 
////            catch {
////                print("unable to create a directory")
////            }
////        }
        
        NSFileManager.defaultManager().createFileAtPath("\(filePath)", contents: nil, attributes: nil)
        download = TCBlobDownloadManager.sharedInstance.downloadFileAtURL(url, toDirectory: path, withName: "\(id).\(ext)", progression: {
            prog, bytesWritten, bytesExpectedToWrite in
//                print("progress is \(Int(prog*100))%")
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
                    self.managedCachedPath = "\(fileURL)"
                    print("\(fileURL)")
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
                print(cachedPath!)
                try NSFileManager.defaultManager().removeItemAtPath(cachedPath!)
                print("file successfully removed")
                self.managedCachedPath = nil
                return true
            }
            catch {
                print("error while deleting")
                return false
            }
        } else {
            return false
        }
    }
}
