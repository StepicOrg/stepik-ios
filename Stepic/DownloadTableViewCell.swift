//
//  DownloadTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton

class DownloadTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var lessonNameLabel: StepikLabel!
    @IBOutlet weak var qualityLabel: StepikLabel!
    @IBOutlet weak var sizeLabel: StepikLabel!

    var video: Video!

    func initWith( _ video: Video) {
        thumbnailImageView.sd_setImage(with: URL(string: video.thumbnailURL), placeholderImage: Images.videoPlaceholder)
        lessonNameLabel.text = "\(video.managedBlock?.managedStep?.managedLesson?.title ?? "")"
        self.video = video

        let size = VideoStoredFileManager(fileManager: FileManager.default).getVideoStoredFile(videoID: video.id)?.size ?? 0
        self.sizeLabel.text = "\(size / 1024 / 1024) \(NSLocalizedString("Mb", comment: ""))"
        self.qualityLabel.text = "\(self.video.cachedQuality ?? "0")p"
    }
}
