//
//  CourseContentMenuViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 02.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CourseContentMenuViewController: MenuTableViewController {

    // Pass data for current vc with some case
    var course = Model.sharedReference.getCurrentCourse()

    override var segueIdentifier: String { return "ShowDetailSegue" }

    override var cellIdentifier: String { return "ParagraphTableViewCell" }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default:
            return course.paragraphs.count
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return CGFloat(220)
        default:
            return CGFloat(66)
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CourseHeaderCell", for: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ParagraphTableViewCell
            cell.configure(with: indexPath.row + 1, course.paragraphs[indexPath.row].name)
            return cell
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = performingSegueSourceCellIndexPath else { fatalError("'prepare(for segue:)' called when no performing segues") }

        if segue.identifier == segueIdentifier {
            let vc = segue.destination as? DetailViewController
            vc?.share = indexPath.row
        }
    }
}
