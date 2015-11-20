//
//  VideoDownloadDelegate.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import DownloadButton

protocol VideoDownloadDelegate {
    func didDownload(video: Video, cancelled: Bool)
    func didGetError(video: Video)
}