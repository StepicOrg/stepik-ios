//
//  TCBlobDownloadManager.swift
//  TCBlobDownloadSwift
//
//  Created by Thibault Charbonnier on 30/12/14.
//  Copyright (c) 2014 thibaultcha. All rights reserved.
//

import Foundation

public let kTCBlobDownloadSessionIdentifier = "tcblobdownloadmanager_downloads"

public let kTCBlobDownloadErrorDomain = "com.tcblobdownloadswift.error"
public let kTCBlobDownloadErrorDescriptionKey = "TCBlobDownloadErrorDescriptionKey"
public let kTCBlobDownloadErrorHTTPStatusKey = "TCBlobDownloadErrorHTTPStatusKey"
public let kTCBlobDownloadErrorFailingURLKey = "TCBlobDownloadFailingURLKey"

public enum TCBlobDownloadError: Int {
    case tcBlobDownloadHTTPError = 1
}

open class TCBlobDownloadManager: NSObject {
    /**
        A shared instance of `TCBlobDownloadManager`.
    */
    open static let sharedInstance = TCBlobDownloadManager()

    /// If `true`, downloads will start immediatly after being created. `true` by default.
    open var startImmediatly = true

    /// The underlying `NSURLSession`.
    open var session: URLSession

    /**
        Custom `NSURLSessionConfiguration` init.

        - parameter config: The configuration used to manage the underlying session.
    */
    public init(config: URLSessionConfiguration) {
        self.session = URLSession()
        super.init()
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        self.session.sessionDescription = "TCBlobDownloadManger session"
    }

    /**
        Default `NSURLSessionConfiguration` init.
    */
    public convenience override init() {
        let config = URLSessionConfiguration.default

        config.timeoutIntervalForRequest = 10000
        //config.HTTPMaximumConnectionsPerHost = 1
        self.init(config: config)
    }

    public convenience init(taskIdentifier: String) {
        let config = URLSessionConfiguration.background(withIdentifier: taskIdentifier)
        config.sessionSendsLaunchEvents = true
        config.timeoutIntervalForRequest = 100000

        self.init(config: config)
    }

    /**
        Base method to start a download, called by other download methods.
    
        - parameter download: Download to start.
    */
    fileprivate func downloadWithDownload(_ download: TCBlobDownload) -> TCBlobDownload {
        self.downloads[download.downloadTask.taskIdentifier] = download

        if self.startImmediatly {
            download.downloadTask.resume()
        }

        return download
    }

    /**
        Start downloading the file at the given URL.
    
        - parameter url: NSURL of the file to download.
        - parameter directory: Directory Where to copy the file once the download is completed. If `nil`, the file will be downloaded in the current user temporary directory/
        - parameter name: Name to give to the file once the download is completed.
        - parameter delegate: An eventual delegate for this download.

        :return: A `TCBlobDownload` instance.
    */
    open func downloadFileAtURL(_ url: URL, toDirectory directory: URL?, withName name: String?, andDelegate delegate: TCBlobDownloadDelegate?) -> TCBlobDownload {
        let downloadTask = self.session.downloadTask(with: url)
        let download = TCBlobDownload(downloadTask: downloadTask, toDirectory: directory, fileName: name, delegate: delegate)

        return self.downloadWithDownload(download)
    }

    /**
        Start downloading the file at the given URL.

        - parameter url: NSURL of the file to download.
        - parameter directory: Directory Where to copy the file once the download is completed. If `nil`, the file will be downloaded in the current user temporary directory/
        - parameter name: Name to give to the file once the download is completed.
        - parameter progression: A closure executed periodically when a chunk of data is received.
        - parameter completion: A closure executed when the download has been completed.

        :return: A `TCBlobDownload` instance.
    */
    open func downloadFileAtURL(_ url: URL, toDirectory directory: URL?, withName name: String?, progression: progressionHandler?, completion: completionHandler?) -> TCBlobDownload {
        let downloadTask = self.session.downloadTask(with: url)
        let download = TCBlobDownload(downloadTask: downloadTask, toDirectory: directory, fileName: name, progression: progression, completion: completion)

        return self.downloadWithDownload(download)
    }

    /**
        Resume a download with previously acquired resume data.
    
        :see: `TCBlobDownload -cancelWithResumeData:` to produce this data.

        - parameter resumeData: Data blob produced by a previous download cancellation.
        - parameter directory: Directory Where to copy the file once the download is completed. If `nil`, the file will be downloaded in the current user temporary directory/
        - parameter name: Name to give to the file once the download is completed.
        - parameter delegate: An eventual delegate for this download.
    
        :return: A `TCBlobDownload` instance.
    */
    open func downloadFileWithResumeData(_ resumeData: Data, toDirectory directory: URL?, withName name: String?, andDelegate delegate: TCBlobDownloadDelegate?) -> TCBlobDownload {
        let downloadTask = self.session.downloadTask(withResumeData: resumeData)
        let download = TCBlobDownload(downloadTask: downloadTask, toDirectory: directory, fileName: name, delegate: delegate)

        return self.downloadWithDownload(download)
    }

    /**
        Gets the downloads in a given state currently being processed by the instance of `TCBlobDownloadManager`.
    
        - parameter state: The state by which to filter the current downloads.
        
        :return: An `Array` of all current downloads with the given state.
    */
    open func currentDownloadsFilteredByState(_ state: URLSessionTask.State?) -> [TCBlobDownload] {
        var downloads = [TCBlobDownload]()

        // TODO: make functional as soon as Dictionary supports reduce/filter.
        for download in self.downloads.values {
            if state == nil || download.downloadTask.state == state {
                downloads.append(download)
            }
        }

        return downloads
    }

    var downloads: [Int: TCBlobDownload] = [:]
    let acceptableStatusCodes = 200...299
}

extension TCBlobDownloadManager: URLSessionDownloadDelegate {

    func validateResponse(_ response: HTTPURLResponse) -> Bool {
        return self.acceptableStatusCodes.contains(response.statusCode)
    }

    // MARK: NSURLSessionDownloadDelegate

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        print("Resume at offset: \(fileOffset) total expected: \(expectedTotalBytes)")
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let download = self.downloads[downloadTask.taskIdentifier] else {
            return
        }
        let progress = totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown ? -1 : Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)

        download.progress = progress

        DispatchQueue.main.async {
            download.delegate?.download(download, didProgress: progress, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite)
            download.progression?(progress, totalBytesWritten, totalBytesExpectedToWrite)
            return
        }
    }

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let download = self.downloads[downloadTask.taskIdentifier] else {
            return
        }
        var fileError: NSError?
        var resultingURL: NSURL?

        do {
            try FileManager.default.replaceItem(at: download.destinationURL as URL, withItemAt: location, backupItemName: nil, options: [], resultingItemURL: &resultingURL)
            download.resultingURL = resultingURL as URL?
        } catch let error1 as NSError {
            fileError = error1
            download.error = fileError
        }
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError sessionError: Error?) {
        guard let download = self.downloads[task.taskIdentifier] else {
            return
        }
        var error: NSError? = sessionError as NSError?
        // Handle possible HTTP errors
        if let response = task.response as? HTTPURLResponse {
            // NSURLErrorDomain errors are not supposed to be reported by this delegate
            // according to https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/URLLoadingSystem/NSURLSessionConcepts/NSURLSessionConcepts.html
            // so let's ignore them as they sometimes appear there for now. (But WTF?)
            if !validateResponse(response) && (error == nil || error!.domain == NSURLErrorDomain) {
                error = NSError(domain: kTCBlobDownloadErrorDomain,
                    code: TCBlobDownloadError.tcBlobDownloadHTTPError.rawValue,
                    userInfo: [kTCBlobDownloadErrorDescriptionKey: "Erroneous HTTP status code: \(response.statusCode)",
                               kTCBlobDownloadErrorFailingURLKey: task.originalRequest!.url!,
                               kTCBlobDownloadErrorHTTPStatusKey: response.statusCode])
            }
        }

        // Remove the reference to the download
        self.downloads.removeValue(forKey: task.taskIdentifier)

        DispatchQueue.main.async {
            download.delegate?.download(download, didFinishWithError: error, atLocation: download.resultingURL)
            download.completion?(error, download.resultingURL)
            return
        }
    }
}
