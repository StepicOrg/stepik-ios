//
//  CatalogMenuViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 24.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CatalogMenuViewController: MenuTableViewController {

    override var segueIdentifier: String { return "ShowCoursesTable" }

    override var cellIdentifier: String { return "StaticCoursesTableViewCell" }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = performingSegueSourceCellIndexPath else { fatalError("'prepare(for segue:)' called when no performing segues") }

        if segue.identifier == segueIdentifier {
            let vc = segue.destination as? RectangularCollectionViewController

            if indexPath.row == 0 { vc?.content = .Undone }
            if indexPath.row == 1 { vc?.content = .Done }
        }
    }
}
