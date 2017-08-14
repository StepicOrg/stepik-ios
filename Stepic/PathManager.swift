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
    fileprivate override init() {}

    fileprivate var directoryPath: URL {
        let fileManager = FileManager.default
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first!
    }

    func getVideoDirectoryURL() throws -> URL {
        let videoURL = directoryPath.appendingPathComponent("Video", isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: videoURL, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            //Error, when directory already exists
            if error.code != 516 {
                print(error.localizedDescription)
                throw error
            }
        }
        return videoURL

    }

    func createVideoWith(id: Int, andExtension ext: String) throws {
        let fileName = "\(id).\(ext)"

        do {
            let fileURL = try getVideoDirectoryURL().appendingPathComponent(fileName, isDirectory: false)
            let filePath = fileURL.path
            if !FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil) {
                let error = NSError(domain: NSCocoaErrorDomain, code: NSFileWriteUnknownError, userInfo: [NSLocalizedDescriptionKey: "Error while creating file at path \(filePath)"])
                throw error
            }
        } catch let error as NSError {
            throw error
        }
    }

    func doesExistVideoWith(id: Int) -> Bool {
        do {
            let filePath = try getPathForVideoWithId(id: id, andExtension: "mp4")
            return try FileManager.default.fileExists(atPath: filePath)
        } catch _ as NSError {
            return false
        }
    }

    func getPathForVideoWithId(id: Int, andExtension ext: String) throws -> String {
        let fileName = "\(id).\(ext)"
        do {
            let fileURL = try getVideoDirectoryURL().appendingPathComponent(fileName, isDirectory: false)
            return fileURL.path
        } catch let error as NSError {
            throw error
        }
    }

    func getPathForStoredVideoWithName(_ fileName: String) throws -> String {
        do {
            let fileURL = try getVideoDirectoryURL().appendingPathComponent(fileName, isDirectory: false)
            return fileURL.path
        } catch let error as NSError {
            throw error
        }
    }

    func deleteVideoFileAtPath(_ path: String) throws {
        do {
            try FileManager.default.removeItem(atPath: path)
        } catch let error as NSError {
            throw error
        }
    }

}
