//
//  DownloadTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import DownloadButton
import UIKit

final class DownloadTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var lessonNameLabel: StepikLabel!
    @IBOutlet weak var qualityLabel: StepikLabel!
    @IBOutlet weak var sizeLabel: StepikLabel!

    func configure(video: Video) {
        self.thumbnailImageView.sd_setImage(
            with: URL(string: video.thumbnailURL),
            placeholderImage: Images.videoPlaceholder
        )
        self.lessonNameLabel.text = "\(video.managedBlock?.managedStep?.managedLesson?.title ?? "")"

        let videoStoredFileManager = VideoStoredFileManager(fileManager: .default)
        let size = videoStoredFileManager.getVideoStoredFile(videoID: video.id)?.size ?? 0

        self.sizeLabel.text = "\(size / 1024 / 1024) \(NSLocalizedString("Mb", comment: ""))"
        self.qualityLabel.text = "\(video.cachedQuality ?? "0")p"
    }
}
