//
//  ParagraphLessonsTableViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 03.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class SectionTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var paragraphIndex: Int!
    var section: SectionViewData!

    // Set for correcting show loading
    var width: CGFloat?

    fileprivate var loadingView: TVLoadingView?

    @IBOutlet var paragraphName: UILabel!
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        paragraphName.text = section.title
        progressLabel.text = section.progressText
        tableView.dataSource = self
        tableView.delegate = self

        tableView.remembersLastFocusedIndexPath = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.section.lessons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonTableViewCell", for: indexPath) as! LessonTableViewCell
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? LessonTableViewCell else { return }
        cell.setup(with: paragraphIndex, indexPath.row + 1, viewData: section.lessons[indexPath.row])
    }
}

extension SectionTableViewController: UICollectionViewDelegateFlowLayout {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LessonTableViewCell.getHeightForCell(with: section.lessons[indexPath.row], width: tableView.bounds.width)
    }

}

extension SectionTableViewController: DetailCourseContentView {

    func update() {
        tableView.reloadData()
    }

    func showLoading(isVisible: Bool) {
        guard isVisible else {
            loadingView?.purge()
            loadingView?.removeFromSuperview()
            loadingView = nil
            return
        }

        guard let width = width else { return }
        let rect = CGRect(x: 0, y: 0, width: width, height: UIScreen.main.bounds.height)

        guard let _ = loadingView else {

            loadingView = TVLoadingView(frame: rect, color: .gray)
            loadingView!.setup()

            self.view.addSubview(loadingView!)
            return
        }
    }
}
