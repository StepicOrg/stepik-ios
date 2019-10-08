//
//  DownloadsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import DownloadButton
import SVProgressHUD
import UIKit

final class DownloadsViewController: UIViewController {
    @IBOutlet weak var tableView: StepikTableView!

    var cachedVideos: [Video] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = []

        self.tableView.register(
            UINib(nibName: "DownloadTableViewCell", bundle: nil),
            forCellReuseIdentifier: "DownloadTableViewCell"
        )

        self.tableView.emptySetPlaceholder = StepikPlaceholder(.emptyDownloads) { [weak self] in
            self?.tabBarController?.selectedIndex = 1
        }
        self.tableView.tableFooterView = UIView()

        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .never
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fetchVideos()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AmplitudeAnalyticsEvents.Downloads.downloadsScreenOpened.send()
    }

    private func fetchVideos() {
        self.cachedVideos = Video.getAllVideos().filter { $0.state == .cached }
        self.tableView.reloadData()
    }

    @IBAction func clearCachePressed(_ sender: UIBarButtonItem) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Downloads.clear, parameters: nil)

        self.askForClearCache(remove: {
            AnalyticsReporter.reportEvent(AnalyticsEvents.Downloads.acceptedClear, parameters: nil)
            SVProgressHUD.show()

            let videos = Video.getAllVideos()
            var shouldBeRemovedCount = videos.count

            for video in videos {
                do {
                    let videoStoredFileManager = VideoStoredFileManager(fileManager: .default)
                    try videoStoredFileManager.removeVideoStoredFile(videoID: video.id)
                    video.cachedQuality = nil
                    CoreDataHelper.instance.save()

                    shouldBeRemovedCount -= 1
                } catch { }
            }

            let completed = videos.count - shouldBeRemovedCount

            if shouldBeRemovedCount == 0 {
                DispatchQueue.main.async {
                    SVProgressHUD.showError(
                        withStatus: "\(NSLocalizedString("FailedToRemoveMessage", comment: "")) \(shouldBeRemovedCount)/\(videos.count) \(NSLocalizedString((completed % 10 == 1 && completed != 11) ? "Video" : "Videos", comment: ""))"
                    )
                }
            } else {
                DispatchQueue.main.async {
                    SVProgressHUD.showSuccess(
                        withStatus: "\(NSLocalizedString("RemovedAllMessage", comment: "")) \(completed) \(NSLocalizedString((completed % 10 == 1 && completed != 11) ? "Video" : "Videos", comment: ""))"
                    )
                }
            }

            DispatchQueue.main.async {
                self.fetchVideos()
            }
        })
    }

    private func askForClearCache(remove: @escaping (() -> Void)) {
        let alert = UIAlertController(
            title: NSLocalizedString("ClearCacheTitle", comment: ""),
            message: NSLocalizedString("ClearCacheMessage", comment: ""),
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Remove", comment: ""),
                style: .destructive,
                handler: { _ in
                    remove()
                }
            )
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))

        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - DownloadsViewController: UITableViewDataSource -

extension DownloadsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cachedVideos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "DownloadTableViewCell",
            for: indexPath
        ) as? DownloadTableViewCell else {
            return UITableViewCell()
        }

        if let video = self.cachedVideos[safe: indexPath.row] {
            cell.configure(video: video)
        }

        return cell
    }
}

// MARK: - DownloadsViewController: UITableViewDelegate -

extension DownloadsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let selectedVideo = self.cachedVideos[safe: indexPath.row],
              let course = selectedVideo.managedBlock?.managedStep?.managedLesson?.managedUnit?.managedSection?.managedCourse else {
            return
        }

        if course.enrolled {
            self.showLessonControllerWith(step: selectedVideo.managedBlock!.managedStep!)
        } else {
            if selectedVideo.managedBlock!.managedStep!.managedLesson!.isPublic {
                self.showLessonControllerWith(step: selectedVideo.managedBlock!.managedStep!)
            } else {
                self.showNotAbleToOpenLessonAlert(lesson: selectedVideo.managedBlock!.managedStep!.managedLesson!, enroll: {
                    let joinBlock : (() -> Void) = { [weak self] in
                        DispatchQueue.main.async {
                            SVProgressHUD.show()
                        }

                        ApiDataDownloader.enrollments.joinCourse(course, delete: false, success: {
                            DispatchQueue.main.async {
                                SVProgressHUD.showSuccess(withStatus: "")
                            }
                            self?.showLessonControllerWith(step: selectedVideo.managedBlock!.managedStep!)
                        }, error: { status in
                            DispatchQueue.main.async {
                                SVProgressHUD.showError(withStatus: status)

                                if let navigationController = self?.navigationController {
                                    Messages.sharedManager.showConnectionErrorMessage(
                                        inController: navigationController
                                    )
                                }
                            }
                        })
                    }

                    if AuthInfo.shared.isAuthorized {
                        joinBlock()
                    } else {
                        RoutingManager.auth.routeFrom(controller: self, success: {
                            joinBlock()
                        }, cancel: nil)
                    }
                })
            }
        }
    }

    private func showLessonControllerWith(step: Step) {
        let assembly = NewLessonAssembly(
            initialContext: .lesson(id: step.lessonId),
            startStep: .id(step.id)
        )

        self.push(module: assembly.makeModule())
    }

    private func showNotAbleToOpenLessonAlert(lesson: Lesson, enroll: @escaping (() -> Void)) {
        let alert = UIAlertController(
            title: NSLocalizedString("NoAccess", comment: ""),
            message: "\(NSLocalizedString("NotEnrolledToCourseMessage", comment: "")) \"\(lesson.managedUnit!.managedSection!.managedCourse!.title)\". \(NSLocalizedString("JoinCourse", comment: ""))?",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("JoinCourse", comment: ""),
                style: .default,
                handler: { _ in
                    enroll()
                }
            )
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))

        self.present(alert, animated: true, completion: nil)
    }
}
