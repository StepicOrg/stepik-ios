//
//  VideoDownloader.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class VideoDownloader: NSObject {
    static let sharedDownloader = VideoDownloader() 
    
    private override init() {}
    
    private var downloadingURLs : [String] = []

    func downloadVideoWithURLs(urls: [String]?, updateProgress : (Float -> Void)? = nil) {
        if let arr = urls {
            for url in arr {
                if !downloadingURLs.contains(url) {
                    downloadingURLs += [url]
                }
            }
        }
    }
    
    func cancelVideoDownloadWithURLs(urls: [String]?) {
        if let arr = urls {
            for url in arr {
                if let id = downloadingURLs.indexOf(url) {
                    downloadingURLs.removeAtIndex(id)
                }
            }
        }
    }
    
    func deleteVideosViewURLs(urls: [String]?) {
        print("delete videos called")
    }
}
