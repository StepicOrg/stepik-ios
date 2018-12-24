//
//  SectionTableViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 08.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton

class SectionTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: StepikLabel!
    @IBOutlet weak var datesLabel: StepikLabel!
    @IBOutlet weak var scoreProgressView: UIProgressView!
    @IBOutlet weak var scoreLabel: StepikLabel!

    @IBOutlet weak var downloadButton: PKDownloadButton!

    override func awakeFromNib() {
        super.awakeFromNib()

        UICustomizer.sharedCustomizer.setCustomDownloadButton(downloadButton)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    fileprivate class func getTextFromSection(_ section: Section) -> String {
        var text = ""
        if section.beginDate != nil {
            text = "\n\(NSLocalizedString("BeginDate", comment: "")): \n\t\(section.beginDate!.getStepicFormatString(withTime: true))"
        }
        if section.softDeadline != nil {
            text = "\(text)\n\(NSLocalizedString("SoftDeadline", comment: "")): \n\t\(section.softDeadline!.getStepicFormatString(withTime: true))"
        }
        if section.hardDeadline != nil {
            text = "\(text)\n\(NSLocalizedString("HardDeadline", comment: "")): \n\t\(section.hardDeadline!.getStepicFormatString(withTime: true))"
        }
        if section.endDate != nil {
            text = "\(text)\n\(NSLocalizedString("EndDate", comment: "")): \n\t\(section.endDate!.getStepicFormatString(withTime: true))"
        }
        return text
    }

    class func heightForCellInSection(_ section: Section) -> CGFloat {
        let titleText = "\(section.position). \(section.title)"
        let datesText = SectionTableViewCell.getTextFromSection(section)
        return 46 + UILabel.heightForLabelWithText(titleText, lines: 0, standardFontOfSize: 14, width: UIScreen.main.bounds.width - 107) + (datesText == "" ? 0 : 8 + UILabel.heightForLabelWithText(datesText, lines: 0, standardFontOfSize: 14, width: UIScreen.main.bounds.width - 107))
    }

    var completedDownloads = 0
    var failedDownloads = 0
    func updateDownloadButton(_ section: Section) {
        if section.isCached {
            self.downloadButton.state = .downloaded
        } else {
            var videos = [Video]()
            // FIXME: section may not have units, unit may not have steps
            for lesson in section.units.compactMap({ $0.lesson }) {
                videos.append(contentsOf: lesson.stepVideos)
            }
            let tasks = videos.compactMap { video in
                // VideoDownloaderManager.shared.get(by: video.id)
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
                            self?.downloadButton.stopDownloadButton?.progress = max(CGFloat(newProgress),
                                                                                self?.downloadButton.stopDownloadButton?.progress ?? 0)
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

    func initWithSection(_ section: Section, sectionDeadline: SectionDeadline? = nil, delegate: PKDownloadButtonDelegate) {
        titleLabel.text = "\(section.position). \(section.title)"
        datesLabel.colorMode = .gray

        if let sectionDeadline = sectionDeadline {
            datesLabel.text = "\(NSLocalizedString("PersonalDeadline", comment: "")) \(sectionDeadline.deadlineDate.getStepicFormatString(withTime: true))"
        } else {
            datesLabel.text = SectionTableViewCell.getTextFromSection(section)
        }

        if let progress = section.progress {
            if progress.cost == 0 {
                scoreProgressView.isHidden = true
                scoreLabel.isHidden = true
            } else {
                scoreProgressView.progress = Float(progress.score) / Float(progress.cost)
                scoreLabel.text = "\(progress.score)/\(progress.cost)"
                scoreProgressView.isHidden = false
                scoreLabel.isHidden = false
            }
        } else {
            scoreProgressView.isHidden = true
            scoreLabel.isHidden = true
        }

        updateDownloadButton(section)

        downloadButton.tag = section.position - 1
        downloadButton.delegate = delegate

        if (!section.isActive && section.testSectionAction == nil) || (section.progressId == nil && !section.isExam) {
            titleLabel.isEnabled = false
            datesLabel.isEnabled = false
            downloadButton.isHidden = true
        } else {
            titleLabel.isEnabled = true
            datesLabel.isEnabled = true
            downloadButton.isHidden = false
        }

    }

}
