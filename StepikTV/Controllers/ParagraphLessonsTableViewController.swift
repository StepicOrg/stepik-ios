//
//  ParagraphLessonsTableViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 03.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class ParagraphLessonsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var paragraphIndex: Int!

    var paragraph: Paragraph!

    @IBOutlet var paragraphName: UILabel!

    @IBOutlet var progressLabel: UILabel!

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        paragraphName.text = paragraph.name
        tableView.dataSource = self
        tableView.delegate = self

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = LessonTableViewCell.estimatedSize

        tableView.remembersLastFocusedIndexPath = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paragraph.lessons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonTableViewCell", for: indexPath) as! LessonTableViewCell

        cell.configure(with: paragraphIndex, indexPath.row + 1, paragraph.lessons[indexPath.row])

        return cell
    }

}
