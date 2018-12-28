//
//  CourseInfoTabSyllabusTableViewDataSource.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 20/12/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class CourseInfoTabSyllabusTableViewDataSource: NSObject,
                                                    UITableViewDelegate,
                                                    UITableViewDataSource {
    weak var delegate: CourseInfoTabSyllabusViewControllerDelegate?

    private var viewModels: [CourseInfoTabSyllabusSectionViewModel]

    private var sectionsIndexCache: [UniqueIdentifierType: Int] = [:]
    private var unitsIndexCache: [UniqueIdentifierType: IndexPath] = [:]

    private var visibleCells: [IndexPath: UITableViewCell] = [:]
    private var visibleSectionHeaders: [Int: UIView] = [:]

    init(viewModels: [CourseInfoTabSyllabusSectionViewModel] = []) {
        self.viewModels = viewModels
        super.init()

        self.buildCache()
    }

    // MARK: Public methods

    func update(viewModels: [CourseInfoTabSyllabusSectionViewModel]) {
        self.viewModels = viewModels
        self.buildCache()
    }

    func mergeViewModel(section: CourseInfoTabSyllabusSectionViewModel) {
        guard let index = self.sectionsIndexCache[section.uniqueIdentifier] else {
            return
        }

        self.viewModels[index] = section
        self.reloadVisibleSectionHeader(affectedIndex: index)
    }

    func mergeViewModel(unit: CourseInfoTabSyllabusUnitViewModel) {
        guard let indexPath = self.unitsIndexCache[unit.uniqueIdentifier] else {
            return
        }

        self.viewModels[indexPath.section].units[indexPath.row] = .normal(viewModel: unit)
        self.reloadVisibleCell(affectedIndexPath: indexPath)
    }

    // MARK: Private methods

    private func reloadVisibleSectionHeader(affectedIndex: Int) {
        guard let view = self.visibleSectionHeaders[affectedIndex],
              let headerView = view as? CourseInfoTabSyllabusSectionView else {
            return
        }

        guard let viewModel = self.viewModels[safe: affectedIndex] else {
            return
        }

        headerView.updateDownloadState(newState: viewModel.downloadState)
    }

    private func reloadVisibleCell(affectedIndexPath: IndexPath) {
        guard let cell = self.visibleCells[affectedIndexPath],
              let tableCell = cell as? CourseInfoTabSyllabusTableViewCell else {
            return
        }

        guard let sectionViewModel = self.viewModels[safe: affectedIndexPath.section],
              let unitWrappedViewModel = sectionViewModel.units[safe: affectedIndexPath.row] else {
            return
        }

        guard case .normal(let unitViewModel) = unitWrappedViewModel else {
            return
        }

        tableCell.updateDownloadState(newState: unitViewModel.downloadState)
    }

    private func buildCache() {
        self.sectionsIndexCache.removeAll(keepingCapacity: true)
        self.unitsIndexCache.removeAll(keepingCapacity: true)

        for (index, viewModel) in self.viewModels.enumerated() {
            self.sectionsIndexCache[viewModel.uniqueIdentifier] = index

            for (row, wrappedViewModel) in viewModel.units.enumerated() {
                guard case .normal(let viewModel) = wrappedViewModel else {
                    continue
                }

                self.unitsIndexCache[viewModel.uniqueIdentifier] = IndexPath(
                    row: row,
                    section: index
                )
            }
        }
    }

    // MARK: Delegate & data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModels.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModels[section].units.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CourseInfoTabSyllabusTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.updateConstraintsIfNeeded()
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView = CourseInfoTabSyllabusSectionView()

        if let viewModel = self.viewModels[safe: section] {
            sectionView.configure(viewModel: viewModel)
            sectionView.onDownloadButtonClick = { [weak self] in
                self?.delegate?.downloadButtonDidClick(viewModel)
            }
        }
        return sectionView
    }

    func tableView(
        _ tableView: UITableView,
        willDisplayHeaderView view: UIView,
        forSection section: Int
    ) {
        self.visibleSectionHeaders[section] = view

        // If section has no unit-placeholders then skip request
        let hasUnitPlaceholders = self.viewModels[section].units.contains(
            where: { unit in
                if case .placeholder = unit {
                    return true
                }
                return false
            }
        )
        if hasUnitPlaceholders {
            self.delegate?.sectionWillDisplay(self.viewModels[section])
        }
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        guard let cell = cell as? CourseInfoTabSyllabusTableViewCell else {
            return
        }

        if let wrappedUnitViewModel = self.viewModels[safe: indexPath.section]?.units[safe: indexPath.row] {
            if case .normal(let unitViewModel) = wrappedUnitViewModel {
                cell.configure(viewModel: unitViewModel)
                cell.onDownloadButtonClick = { [weak self] in
                    self?.delegate?.downloadButtonDidClick(unitViewModel)
                }
                cell.hideLoading()
            } else {
                cell.showLoading()
            }
        }

        self.visibleCells[indexPath] = cell
    }

    func tableView(
        _ tableView: UITableView,
        didEndDisplaying cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        self.visibleCells.removeValue(forKey: indexPath)
    }

    func tableView(
        _ tableView: UITableView,
        didEndDisplayingHeaderView view: UIView,
        forSection section: Int
    ) {
        self.visibleSectionHeaders.removeValue(forKey: section)
    }
}
