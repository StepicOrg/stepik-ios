//
//  LessonsTableViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 24/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class LessonsTableViewController: UITableViewController {

    // MARK: Instance Properties

    var presenter: LessonsPresenter!

    private var lessons = [LessonsViewData]() {
        didSet {
            tableView.reloadData()
        }
    }

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerNib(for: LessonTableViewCell.self)
        presenter.refresh()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessons.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LessonTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.descriptionTitleLabel.text = lessons[indexPath.row].title

        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - LessonsTableViewController: LessonsView -

extension LessonsTableViewController: LessonsView {
    func setLessons(_ lessons: [LessonsViewData]) {
        self.lessons = lessons
    }

    func displayError(title: String, message: String) {
        presentAlert(withTitle: title, message: message)
    }
}
