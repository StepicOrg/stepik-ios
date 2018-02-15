//
//  MasterTableViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 03.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    /**
     Reuse identifier of TableView cells that perform showing detailed views.

     Overridden by subclasses.
     */
    var cellIdentifier: String { return "" }

    /**
     TableView cells output segue identifier for showing detailed views.

     Overridden by subclasses.
     */
    var segueIdentifier: String { return "" }

    /**
     IndexPath of cell which outside segue performing. Use this property to configure showing detail ViewController knowing index of data in source collection.
     */
    final var performingSegueSourceCellIndexPath: IndexPath? { return performingIndexPath }

    // MARK: Private properties

    private var performingIndexPath: IndexPath?

    private var lastPerformedIndexPath: IndexPath? { didSet { performingIndexPath = nil } }

    private let delayedSeguesOperationQueue = OperationQueue()

    private static let performSegueDelay: TimeInterval = 0.1

    // MARK: UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.remembersLastFocusedIndexPath = true
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard let _ = sender as? UITableViewCell else { return true }
        return false
    }

    func moveToDetailView(from tableViewCellIndexPath: IndexPath) {

    }

    // MARK: UITableViewDelegate

    override func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {

        guard let focusedCell = context.nextFocusedView as? UITableViewCell, focusedCell.isDescendant(of: tableView) else {
            if let indexPath = lastPerformedIndexPath {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.moveToDetailView(from: indexPath)
                }
            }
            return
        }

        guard focusedCell.reuseIdentifier == cellIdentifier else { return }

        guard let focusedIndexPath = context.nextFocusedIndexPath else { return }

        // Cancel any previously queued segues.
        delayedSeguesOperationQueue.cancelAllOperations()

        // Create a `BlockOperation` to perform the detail segue after a delay.
        let performSegueOperation = BlockOperation()

        performSegueOperation.addExecutionBlock { [weak self, unowned performSegueOperation] in
            Thread.sleep(forTimeInterval: MenuTableViewController.performSegueDelay)

            guard !performSegueOperation.isCancelled && focusedIndexPath != self?.lastPerformedIndexPath else { return }

            OperationQueue.main.addOperation {
                // Record the performing segue for cell with indexPath
                self?.performingIndexPath = focusedIndexPath

                // Perform the segue to show the detail view controller.
                self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: focusedCell)

                // Record the last performed segue for cell with indexPath
                self?.lastPerformedIndexPath = focusedIndexPath

                self?.tableView.selectRow(at: focusedIndexPath, animated: true, scrollPosition: .none)
            }
        }

        delayedSeguesOperationQueue.addOperation(performSegueOperation)
    }

}
