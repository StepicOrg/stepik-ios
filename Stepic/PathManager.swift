//
//  PathManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 23.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class PathManager: NSObject {
    
    static let sharedManager = PathManager()
    private override init() {}
    
    private var directoryPath : NSURL {
        let fileManager = NSFileManager.defaultManager()
        let paths = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return paths.first!
    }
    
    func getVideoDirectoryURL() throws -> NSURL {
        let videoURL = directoryPath.URLByAppendingPathComponent("Video", isDirectory: true)
        
        do { 
            try NSFileManager.defaultManager().createDirectoryAtURL(videoURL, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError { 
            //Error, when directory already exists
            if error.code != 516 {
                print(error.localizedDescription)
                throw error
            }
        }
        return videoURL

    }
    
    func createVideoWith(id id: Int, andExtension ext: String) throws {
        let fileName = "\(id).\(ext)"
        
        do {
            let fileURL = try getVideoDirectoryURL().URLByAppendingPathComponent(fileName, isDirectory: false)
            let filePath = fileURL.path!
            if !NSFileManager.defaultManager().createFileAtPath(filePath, contents: nil, attributes: nil) {
                let error = NSError(domain: NSCocoaErrorDomain, code: NSFileWriteUnknownError, userInfo: [NSLocalizedDescriptionKey : "Error while creating file at path \(filePath)"])
                throw error
            }
        }
        catch let error as NSError {
            throw error
        }
    }
    
    func doesExistVideoWith(id id: Int) -> Bool {
        do {
            let filePath = try getPathForVideoWithId(id: id, andExtension: "mp4")
            return try NSFileManager.defaultManager().fileExistsAtPath(filePath)
        }
        catch let error as NSError{
            return false
        }
    }
    
    func getPathForVideoWithId(id id: Int, andExtension ext: String) throws -> String {
        let fileName = "\(id).\(ext)"
        do {
            let fileURL = try getVideoDirectoryURL().URLByAppendingPathComponent(fileName, isDirectory: false)
            return fileURL.path!
        }
        catch let error as NSError{
            throw error
        }
    }
    
    func getPathForStoredVideoWithName(fileName: String) throws -> String {
        do {
            let fileURL = try getVideoDirectoryURL().URLByAppendingPathComponent(fileName, isDirectory: false)
            return fileURL.path!
        }
        catch let error as NSError{
            throw error
        }
    }
    
    func deleteVideoFileAtPath(path: String) throws {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(path)
        }
        catch let error as NSError {
            throw error
        }
    }
    
}
