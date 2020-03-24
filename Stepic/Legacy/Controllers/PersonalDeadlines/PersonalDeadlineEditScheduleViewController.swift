//
//  PersonalDeadlineEditScheduleViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import ActionSheetPicker_3_0
import Foundation
import Presentr
import UIKit

@available(*, deprecated, message: "Class to incapsulate edit & delete logic")
final class PersonalDeadlineEditDeleteAlertLegacyAssembly: Assembly {
    private let course: Course
    private let presentingViewController: UIViewController
    private let updateCompletion: (() -> Void)?

    init(
        course: Course,
        presentingViewController: UIViewController,
        updateCompletion: (() -> Void)? = nil
    ) {
        self.course = course
        self.presentingViewController = presentingViewController
        self.updateCompletion = updateCompletion
    }

    func makeModule() -> UIViewController {
        let presentr: Presentr = {
            let presenter = Presentr(presentationType: .popup)
            presenter.roundCorners = true
            return presenter
        }()

        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("Cancel", comment: ""),
                style: .cancel,
                handler: nil
            )
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("EditSchedule", comment: ""),
                style: .default,
                handler: { _ in
                    AnalyticsReporter.reportEvent(AnalyticsEvents.PersonalDeadlines.EditSchedule.changePressed)
                    let viewController = PersonalDeadlineEditScheduleLegacyAssembly(
                        course: self.course
                    ).makeModule()
                    (viewController as? PersonalDeadlineEditScheduleViewController)?.onSavePressed = {
                        self.updateCompletion?()
                    }
                    self.presentingViewController.customPresentViewController(
                        presentr,
                        viewController: viewController,
                        animated: true
                    )
                }
            )
        )
        alert.addAction(
            UIAlertAction(
                title: NSLocalizedString("DeleteSchedule", comment: ""),
                style: .destructive,
                handler: { _ in
                    AnalyticsReporter.reportEvent(AnalyticsEvents.PersonalDeadlines.deleted)
                    SVProgressHUD.show()
                    PersonalDeadlinesService().deleteDeadline(for: self.course).done { _ in
                        SVProgressHUD.dismiss()
                    }.ensure {
                        self.updateCompletion?()
                    }.catch { _ in
                        SVProgressHUD.showError(withStatus: nil)
                    }
                }
            )
        )
        return alert
    }
}

@available(*, deprecated, message: "Class to initialize personal deadlines settings w/o storyboards logic")
final class PersonalDeadlineEditScheduleLegacyAssembly: Assembly {
    private let course: Course

    init(course: Course) {
        self.course = course
    }

    func makeModule() -> UIViewController {
        guard let modesVC = ControllerHelper.instantiateViewController(
            identifier: "PersonalDeadlineEditScheduleViewController",
            storyboardName: "PersonalDeadlines"
        ) as? PersonalDeadlineEditScheduleViewController else {
                fatalError()
        }
        modesVC.course = self.course

        return modesVC
    }
}

final class PersonalDeadlineEditScheduleViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: FullHeightTableView!

    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    var course: Course?
    var sectionDeadlinesData: [SectionDeadlineData] = []
    var onSavePressed: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.snp.makeConstraints { $0.width.equalTo(UIScreen.main.bounds.width - 80) }
        self.saveButton.setRoundedCorners(cornerRadius: 8, borderWidth: 1, borderColor: .stepikLightBlue)

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(
            UINib(nibName: "PersonalDeadlineTableViewCell", bundle: nil),
            forCellReuseIdentifier: "PersonalDeadlineTableViewCell"
        )

        self.initSectionDeadlinesData()
        self.tableView.reloadData()

        self.localize()
        self.colorize()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.view.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    private func localize() {
        self.titleLabel.text = NSLocalizedString("EditSchedule", comment: "")
        self.cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        self.saveButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
    }

    private func colorize() {
        self.view.backgroundColor = .stepikAlertBackground
        self.titleLabel.textColor = .stepikPrimaryText
        self.saveButton.setTitleColor(.stepikLightBlue, for: .normal)
        self.saveButton.layer.borderColor = UIColor.stepikLightBlue.cgColor
        self.cancelButton.setTitleColor(.stepikPrimaryText, for: .normal)
    }

    private func initSectionDeadlinesData() {
        guard let course = course else {
            return
        }
        sectionDeadlinesData = []
        for section in course.sections {
            if let sectionDeadline: SectionDeadline = course.sectionDeadlines?.first(where: { $0.section == section.id }) {
                sectionDeadlinesData += [SectionDeadlineData(section: section, deadline: sectionDeadline.deadlineDate)]
            }
        }
    }

    @IBAction func savePressed(_ sender: Any) {
        guard let course = course else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        AnalyticsReporter.reportEvent(AnalyticsEvents.PersonalDeadlines.EditSchedule.Time.saved)
        let newDeadlines = sectionDeadlinesData.map { $0.sectionDeadline }
        SVProgressHUD.show()
        PersonalDeadlinesService().changeDeadline(for: course, newDeadlines: newDeadlines).done { [weak self] _ in
            SVProgressHUD.dismiss()
            self?.onSavePressed?()
            self?.dismiss(animated: true, completion: nil)
        }.catch {
            _ in
            SVProgressHUD.showError(withStatus: nil)
        }
    }

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension PersonalDeadlineEditScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AnalyticsReporter.reportEvent(AnalyticsEvents.PersonalDeadlines.EditSchedule.Time.opened)
        let approximateYearInSeconds: Double = 60 * 60 * 24 * 30 * 365
        ActionSheetDatePicker.show(withTitle: NSLocalizedString("SelectTimeTitle", comment: ""), datePickerMode: UIDatePicker.Mode.dateAndTime, selectedDate: sectionDeadlinesData[indexPath.row].deadline, minimumDate: Date(), maximumDate: Date().addingTimeInterval(approximateYearInSeconds), doneBlock: {
            [weak self]
            _, value, _ in
            guard let date = value as? Date else {
                return
            }
            self?.tableView.deselectRow(at: indexPath, animated: true)
            self?.sectionDeadlinesData[indexPath.row].deadline = date
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }, cancel: {
            [weak self]
            _ in
            AnalyticsReporter.reportEvent(AnalyticsEvents.PersonalDeadlines.EditSchedule.Time.closed)
            self?.tableView.deselectRow(at: indexPath, animated: true)
        }, origin: tableView.cellForRow(at: indexPath))
    }
}

extension PersonalDeadlineEditScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.course?.sections.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "PersonalDeadlineTableViewCell",
            for: indexPath
        ) as? PersonalDeadlineTableViewCell else {
            return UITableViewCell()
        }

        cell.initWith(data: self.sectionDeadlinesData[indexPath.row])

        return cell
    }
}

struct SectionDeadlineData {
    var title: String
    var sectionID: Int
    var deadline: Date

    init(section: Section, deadline: Date) {
        self.title = section.title
        self.sectionID = section.id
        self.deadline = deadline
    }

    var sectionDeadline: SectionDeadline {
        SectionDeadline(section: self.sectionID, deadlineDate: self.deadline)
    }
}
