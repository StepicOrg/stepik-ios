//
//  DownloadsViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.11.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton
import SVProgressHUD

class DownloadsViewController: UIViewController {

    @IBOutlet weak var tableView: StepikTableView!

    var stored: [Video] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = []

        tableView.register(UINib(nibName: "DownloadTableViewCell", bundle: nil), forCellReuseIdentifier: "DownloadTableViewCell")

        tableView.emptySetPlaceholder = StepikPlaceholder(.emptyDownloads) { [weak self] in
            self?.tabBarController?.selectedIndex = 1
        }
        self.tableView.tableFooterView = UIView()

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        }
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AmplitudeAnalyticsEvents.Downloads.downloadsScreenOpened.send()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchVideos()
    }

    func fetchVideos() {
        stored = []
        let videos = Video.getAllVideos()

        for video in videos {
            if video.state == VideoState.cached {
                stored += [video]
            }
        }

        tableView.reloadData()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showProfile" {
            let dvc = segue.destination
            dvc.hidesBottomBarWhenPushed = true
        }

        if segue.identifier == "showSteps" {
            let dvc = segue.destination as! LessonViewController
            dvc.hidesBottomBarWhenPushed = true

            let step = sender as! Step
            if let lesson = step.managedLesson {
                dvc.initObjects = (lesson: lesson, startStepId: lesson.steps.index(of: step) ?? 0, context: .lesson)
            }
        }
    }

    func askForClearCache(remove: @escaping (() -> Void)) {
        let alert = UIAlertController(title: NSLocalizedString("ClearCacheTitle", comment: ""), message: NSLocalizedString("ClearCacheMessage", comment: ""), preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Remove", comment: ""), style: UIAlertAction.Style.destructive, handler: {
            _ in
            remove()
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertAction.Style.cancel, handler: {
            _ in
        }))

        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func clearCachePressed(_ sender: UIBarButtonItem) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.Downloads.clear, parameters: nil)
        askForClearCache(remove: {
            AnalyticsReporter.reportEvent(AnalyticsEvents.Downloads.acceptedClear, parameters: nil)
            SVProgressHUD.show()

            let videos = Video.getAllVideos()

            var shouldBeRemovedCount = videos.count
            for video in videos {
                do {
                    try VideoStoredFileManager(fileManager: FileManager.default).removeVideoStoredFile(videoID: video.id)
                    video.cachedQuality = nil
                    CoreDataHelper.instance.save()

                    shouldBeRemovedCount -= 1
                } catch { }
            }

            let completed = videos.count - shouldBeRemovedCount
            if shouldBeRemovedCount == 0 {
                UIThread.performUI({SVProgressHUD.showError(withStatus: "\(NSLocalizedString("FailedToRemoveMessage", comment: "")) \(shouldBeRemovedCount)/\(videos.count) \(NSLocalizedString((completed % 10 == 1 && completed != 11) ? "Video" : "Videos", comment: ""))")})
            } else {
                UIThread.performUI({SVProgressHUD.showSuccess(withStatus: "\(NSLocalizedString("RemovedAllMessage", comment: "")) \(completed) \(NSLocalizedString((completed % 10 == 1 && completed != 11) ? "Video" : "Videos", comment: ""))")})
            }

            UIThread.performUI({self.fetchVideos()})
        })
    }

}

extension DownloadsViewController : UITableViewDelegate {

    func showLessonControllerWith(step: Step) {
        self.performSegue(withIdentifier: "showSteps", sender: step)
    }

    func showNotAbleToOpenLessonAlert(lesson: Lesson, enroll: @escaping (() -> Void)) {
        let alert = UIAlertController(title: NSLocalizedString("NoAccess", comment: ""), message: "\(NSLocalizedString("NotEnrolledToCourseMessage", comment: "")) \"\(lesson.managedUnit!.managedSection!.managedCourse!.title)\". \(NSLocalizedString("JoinCourse", comment: ""))?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("JoinCourse", comment: ""), style: .default, handler: {
            _ in
            enroll()
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedVideo: Video! = stored[(indexPath as NSIndexPath).row]

        if let course = selectedVideo.managedBlock?.managedStep?.managedLesson?.managedUnit?.managedSection?.managedCourse {
            let enterDownloadBlock = {
                [weak self] in
                if course.enrolled {
                    self?.showLessonControllerWith(step: selectedVideo.managedBlock!.managedStep!)
                } else {
                    if selectedVideo.managedBlock!.managedStep!.managedLesson!.isPublic {
                        self?.showLessonControllerWith(step: selectedVideo.managedBlock!.managedStep!)
                    } else {
                        self?.showNotAbleToOpenLessonAlert(lesson: selectedVideo.managedBlock!.managedStep!.managedLesson!, enroll: {
                            let joinBlock : (() -> Void) = {
                                [weak self] in
                                UIThread.performUI({
                                    SVProgressHUD.show()
                                })
                                ApiDataDownloader.enrollments.joinCourse(course, delete: false, success: {
                                    UIThread.performUI({SVProgressHUD.showSuccess(withStatus: "")})
                                    self?.showLessonControllerWith(step: selectedVideo.managedBlock!.managedStep!)
                                    }, error: {
                                        status in
                                        UIThread.performUI({SVProgressHUD.showError(withStatus: status)})
                                        UIThread.performUI({
                                            if let navigation = self?.navigationController {
                                                Messages.sharedManager.showConnectionErrorMessage(inController: navigation)
                                            }
                                        })
                                })
                            }
                            if AuthInfo.shared.isAuthorized {
                                joinBlock()
                            } else {
                                if let s = self {
                                    RoutingManager.auth.routeFrom(controller: s, success: {
                                            joinBlock()
                                    }, cancel: nil)
                                }
                            }
                        })
                    }
                }

            }
            enterDownloadBlock()
        } else {
            print("Something bad happened")
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DownloadsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stored.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadTableViewCell", for: indexPath) as! DownloadTableViewCell

        cell.initWith(stored[(indexPath as NSIndexPath).row])

        return cell
    }
}
