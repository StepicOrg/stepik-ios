//
//  UnitTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 09.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton
import SDWebImage

class UnitTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var downloadButton: PKDownloadButton!
    @IBOutlet weak var progressView: UIView!
    @IBOutlet weak var scoreProgressView: UIProgressView!
    @IBOutlet weak var scoreLabel: StepikLabel!
    @IBOutlet weak var coverImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        UICustomizer.sharedCustomizer.setCustomDownloadButton(downloadButton)
//        progressView.setRoundedBounds(width: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    class func heightForCellWithUnit(_ unit: Unit) -> CGFloat {
        let defaultTitle = ""
        let text = "\(unit.position). \(unit.lesson?.title ?? defaultTitle)"
        return 50 + UILabel.heightForLabelWithText(text, lines: 0, standardFontOfSize: 14, width: UIScreen.main.bounds.width - 129)

    }

    var completedDownloads = 0
    var failedDownloads = 0

    func updateDownloadButton(_ unit: Unit) {
        if let lesson = unit.lesson {
            if lesson.isCached {
                downloadButton.state = .downloaded
            } else {
                let videos = lesson.stepVideos
                let tasks = videos.compactMap { video in
                    VideoDownloaderManager.shared.get(by: video.id)
                }

                let progress = tasks.map({ $0.progress }).reduce(0.0, +) / Float(tasks.count)

                if progress < 1.0 {
                    self.downloadButton.state = .downloading
                    self.downloadButton.stopDownloadButton?.progress = CGFloat(progress)

                    for task in tasks {
                        task.progressReporter = { [weak self] progress in
                            // When some task updated then recalculate ALL progresses
                            let newProgress = tasks.map({ $0.progress }).reduce(0.0, +) / Float(tasks.count)

                            DispatchQueue.main.async {
                                self?.downloadButton.stopDownloadButton?.progress = CGFloat(newProgress)
                            }
                        }

                        task.completionReporter = { [weak self] _ in
                            guard let strongSelf = self else {
                                return
                            }

                            // When some task finished then increment `completed` counter
                            strongSelf.completedDownloads += 1

                            if strongSelf.completedDownloads + strongSelf.failedDownloads == tasks.count {
                                DispatchQueue.main.async {
                                    strongSelf.downloadButton.state = strongSelf.failedDownloads == 0 ? .downloaded : .startDownload
                                }
                            }

                            CoreDataHelper.instance.save()
                        }

                        task.failureReporter = { [weak self] _ in
                            guard let strongSelf = self else {
                                return
                            }

                            // When some task failed then increment `failed` counter
                            self?.failedDownloads += 1

                            if strongSelf.completedDownloads + strongSelf.failedDownloads == tasks.count {
                                DispatchQueue.main.async {
                                    strongSelf.downloadButton.state = strongSelf.failedDownloads == 0 ? .downloaded : .startDownload
                                }
                            }

                            CoreDataHelper.instance.save()
                        }
                    }
                } else {
                    downloadButton.state = .startDownload
                }
            }
        }
    }

    func initWithUnit(_ unit: Unit, delegate: PKDownloadButtonDelegate) {
        let defaultTitle = ""
        titleLabel.text = "\(unit.position). \(unit.lesson?.title ?? defaultTitle)"

        updateDownloadButton(unit)

        downloadButton.tag = unit.position - 1
        downloadButton.delegate = delegate

        progressView.backgroundColor = UIColor.white
        if let passed = unit.progress?.isPassed {
            if passed {
                progressView.backgroundColor = UIColor.stepicGreen
            }
        }

        if let progress = unit.progress {
                if progress.cost == 0 {
                    scoreProgressView.isHidden = true
                    scoreLabel.isHidden = true
                } else {
                    scoreProgressView.progress = Float(progress.score) / Float(progress.cost)
                    scoreLabel.text = "\(progress.score)/\(progress.cost)"
                }
        }

        if !(unit.isActive || unit.section?.testSectionAction != nil) {
            titleLabel.isEnabled = false
            downloadButton.isHidden = true
            scoreProgressView.isHidden = true
            scoreLabel.isHidden = true
        }

        if let coverURL = unit.lesson?.coverURL {
            coverImageView.sd_setImage(with: URL(string: coverURL), placeholderImage: Images.lessonPlaceholderImage.size50x50)
        } else {
            coverImageView.image = Images.lessonPlaceholderImage.size50x50
        }

    }
}
