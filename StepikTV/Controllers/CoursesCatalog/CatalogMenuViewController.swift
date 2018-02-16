//
//  CatalogMenuViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 24.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CatalogMenuViewController: MenuTableViewController {

    var presenter: CatalogPresenter?

    override func awakeFromNib() {
        super.awakeFromNib()

        let splitroot = splitViewController as! MenuSplitViewController

        self.presenter = CatalogPresenter(splitview: splitroot, masterview: self, coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.refresh()
    }

    override var segueIdentifier: String { return "ShowCoursesTable" }
    override var cellIdentifier: String { return "RightDetailedCustomTableViewCell" }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = performingSegueSourceCellIndexPath else { fatalError("'prepare(for segue:)' called when no performing segues") }

        guard segue.identifier == segueIdentifier else { return }

        guard let vc = segue.destination as? CatalogDetailView else { return }

        presenter?.setDetailViewToProvideData(vc, width: Float(UIScreen.main.bounds.width - self.view.bounds.width), by: indexPath)
    }
}

extension CatalogMenuViewController: CatalogMenuView {

    func provide(count: Int, at indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RightDetailedCustomTableViewCell
            cell.detailedLabel.text = "\(count)"
        tableView.reloadData()
    }
}
