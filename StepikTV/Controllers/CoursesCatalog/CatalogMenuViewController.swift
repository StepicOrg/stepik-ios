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
        self.presenter = CatalogPresenter(view: self, coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.refresh()
    }

    override var segueIdentifier: String { return "ShowCoursesTable" }
    override var cellIdentifier: String { return "StaticCoursesTableViewCell" }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = performingSegueSourceCellIndexPath else { fatalError("'prepare(for segue:)' called when no performing segues") }

        guard segue.identifier == segueIdentifier else { return }

        guard let vc = segue.destination as? RectangularCollectionViewController else { return }
        presenter?.setDetailViewToProvideData(vc, by: indexPath)
    }
}

extension CatalogMenuViewController: CatalogView {

    func showNoticeMessage() {

    }
}
