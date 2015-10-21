//
//  TCBlobDownload.swift
//  TCBlobDownloadSwift
//
//  Created by Thibault Charbonnier on 30/12/14.
//  Copyright (c) 2014 thibaultcha. All rights reserved.
//

import Foundation

public typealias progressionHandler = ((progress: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) -> Void)!
public typealias completionHandler = ((error: NSError?, location: NSURL?) -> Void)!

public class TCBlobDownload {
    /// The underlying download task.
    public let downloadTask: NSURLSessionDownloadTask

    /// An optional delegate to get notified of events.
    public weak var delegate: TCBlobDownloadDelegate?

    /// An optional progression closure periodically executed when a chunk of data has been received.
    public var progression: progressionHandler

    /// An optional completion closure executed when a download was completed by the download task.
    public var completion: completionHandler

    /// An optional file name set by the user.
    private let preferedFileName: String?

    /// An optional destination path for the file. If nil, the file will be downloaded in the current user temporary directory.
    private let directory: NSURL?

    /// Will contain an error if the downloaded file couldn't be moved to its final destination.
    var error: NSError?

    /// Current progress of the download, a value between 0 and 1. 0 means nothing was received and 1 means the download is completed.
    public var progress: Float = 0

    /// If the moving of the file after downloading was successful, will contain the `NSURL` pointing to the final file.
    public var resultingURL: NSURL?

    /// A computed property to get the filename of the downloaded file.
    public var fileName: String? {
        return self.preferedFileName ?? self.downloadTask.response?.suggestedFilename
    }

    /// A computed destination URL depending on the `destinationPath`, `fileName`, and `suggestedFileName` from the underlying `NSURLResponse`.
    public var destinationURL: NSURL {
        let destinationPath = self.directory ?? NSURL(fileURLWithPath: NSTemporaryDirectory())

        return NSURL(string: self.fileName!, relativeToURL: destinationPath)!.URLByStandardizingPath!
    }

    /**
        Initialize a new download assuming the `NSURLSessionDownloadTask` was already created.
    
        - parameter downloadTask: The underlying download task for this download.
        - parameter directory: The directory where to move the downloaded file once completed.
        - parameter fileName: The preferred file name once the download is completed.
        - parameter delegate: An optional delegate for this download.
    */
    init(downloadTask: NSURLSessionDownloadTask, toDirectory directory: NSURL?, fileName: String?, delegate: TCBlobDownloadDelegate?) {
        self.downloadTask = downloadTask
        self.directory = directory
        self.preferedFileName = fileName
        self.delegate = delegate
    }

    /**
        
    */
    convenience init(downloadTask: NSURLSessionDownloadTask, toDirectory directory: NSURL?, fileName: String?, progression: progressionHandler?, completion: completionHandler?) {
        self.init(downloadTask: downloadTask, toDirectory: directory, fileName: fileName, delegate: nil)
        self.progression = progression
        self.completion = completion
    }

    /**
        Cancel a download. The download cannot be resumed after calling this method.
    
        :see: `NSURLSessionDownloadTask -cancel`
    */
    public func cancel() {
        self.downloadTask.cancel()
    }

    /**
        Suspend a download. The download can be resumed after calling this method.
    
        :see: `TCBlobDownload -resume`
        :see: `NSURLSessionDownloadTask -suspend`
    */
    public func suspend() {
        self.downloadTask.suspend()
    }

    /**
        Resume a previously suspended download. Can also start a download if not already downloading.
    
        :see: `NSURLSessionDownloadTask -resume`
    */
    public func resume() {
        self.downloadTask.resume()
    }

    /**
        Cancel a download and produce resume data. If stored, this data can allow resuming the download at its previous state.

        :see: `TCBlobDownloadManager -downloadFileWithResumeData`
        :see: `NSURLSessionDownloadTask -cancelByProducingResumeData`

        - parameter completionHandler: A completion handler that is called when the download has been successfully canceled. If the download is resumable, the completion handler is provided with a resumeData object.
    */
    public func cancelWithResumeData(completionHandler: (NSData?) -> Void) {
        self.downloadTask.cancelByProducingResumeData(completionHandler)
    }

    // TODO: remaining time
    // TODO: instanciable TCBlobDownloads
}

public protocol TCBlobDownloadDelegate: class {
    /**
        Periodically informs the delegate that a chunk of data has been received (similar to `NSURLSession -URLSession:dataTask:didReceiveData:`).
    
        :see: `NSURLSession -URLSession:dataTask:didReceiveData:`
    
        - parameter download: The download that received a chunk of data.
        - parameter progress: The current progress of the download, between 0 and 1. 0 means nothing was received and 1 means the download is completed.
        - parameter totalBytesWritten: The total number of bytes the download has currently written to the disk.
        - parameter totalBytesExpectedToWrite: The total number of bytes the download will write to the disk once completed.
    */
    func download(download: TCBlobDownload, didProgress progress: Float, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)

    /**
        Informs the delegate that the download was completed (similar to `NSURLSession -URLSession:task:didCompleteWithError:`).
    
        :see: `NSURLSession -URLSession:task:didCompleteWithError:`
    
        - parameter download: The download that received a chunk of data.
        - parameter error: An eventual error. If `nil`, consider the download as being successful.
        - parameter location: The location where the downloaded file can be found.
    */
    func download(download: TCBlobDownload, didFinishWithError error: NSError?, atLocation location: NSURL?)
}

// MARK: Printable

extension TCBlobDownload: CustomStringConvertible {
    public var description: String {
        var parts: [String] = []
        var state: String
        
        switch self.downloadTask.state {
            case .Running: state = "running"
            case .Completed: state = "completed"
            case .Canceling: state = "canceling"
            case .Suspended: state = "suspended"
        }
        
        parts.append("TCBlobDownload")
        parts.append("URL: \(self.downloadTask.originalRequest!.URL)")
        parts.append("Download task state: \(state)")
        parts.append("destinationPath: \(self.directory)")
        parts.append("fileName: \(self.fileName)")
        
        return parts.joinWithSeparator(" | ")
    }
}
