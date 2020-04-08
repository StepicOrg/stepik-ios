//
//  PersonalDeadlinesModeSelectionViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Presentr
import SnapKit
import SVProgressHUD
import UIKit

@available(*, deprecated, message: "Class to initialize personal deadlines selection w/o storyboards logic")
final class PersonalDeadlinesModeSelectionLegacyAssembly: Assembly {
    private let course: Course
    private let updateCompletion: (() -> Void)?

    init(course: Course, updateCompletion: (() -> Void)?) {
        self.course = course
        self.updateCompletion = updateCompletion
    }

    func makeModule() -> UIViewController {
        guard let modesVC = ControllerHelper.instantiateViewController(
            identifier: "PersonalDeadlinesModeSelectionViewController",
            storyboardName: "PersonalDeadlines"
        ) as? PersonalDeadlinesModeSelectionViewController else {
            fatalError()
        }
        modesVC.course = self.course
        modesVC.onDeadlineSelected = {
            self.updateCompletion?()

            NotificationsRegistrationService(
                presenter: NotificationsRequestOnlySettingsAlertPresenter(),
                analytics: .init(source: .personalDeadline)
            ).registerForRemoteNotifications()
        }

        return modesVC
    }
}

final class PersonalDeadlinesModeSelectionViewController: UIViewController {
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cancelButton: UIButton!

    let modes: [DeadlineMode] = [.hobby, .standard, .extreme]
    var course: Course?
    var onDeadlineSelected: (() -> Void)?

    private var modeButtonSize: CGSize {
        let width = CGFloat(Int((collectionView.bounds.width - CGFloat(modes.count - 1) * 12) / CGFloat(modes.count)))
        let height = width + 44
        return CGSize(width: width, height: height)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.register(
            UINib(nibName: "PersonalDeadlineModeCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "PersonalDeadlineModeCollectionViewCell"
        )

        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.questionLabel.snp.makeConstraints { $0.width.equalTo(UIScreen.main.bounds.width - 80) }

        self.colorize()
        self.localize()

        AnalyticsReporter.reportEvent(AnalyticsEvents.PersonalDeadlines.Mode.opened)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.layoutSubviews()
        self.collectionView.snp.makeConstraints { $0.height.equalTo(modeButtonSize.height) }
        self.updateCollectionLayout()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.updateCollectionLayout()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.view.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    @IBAction
    func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        AnalyticsReporter.reportEvent(AnalyticsEvents.PersonalDeadlines.Mode.closed)
    }

    func didSelectMode(mode: DeadlineMode) {
        guard let course = course else {
            self.dismiss(animated: true, completion: nil)
            return
        }

        AnalyticsReporter.reportEvent(
            AnalyticsEvents.PersonalDeadlines.Mode.chosen,
            parameters: ["hours": mode.getModeInfo().weeklyLoadHours]
        )
        AmplitudeAnalyticsEvents.PersonalDeadlines.created(weeklyLoadHours: mode.getModeInfo().weeklyLoadHours).send()

        SVProgressHUD.show()

        PersonalDeadlinesService().countDeadlines(for: course, mode: mode).done {
            SVProgressHUD.dismiss()
            self.onDeadlineSelected?()

            NotificationsRegistrationService(
                presenter: NotificationsRequestOnlySettingsAlertPresenter(),
                analytics: .init(source: .personalDeadline)
            ).registerForRemoteNotifications()

            self.dismiss(animated: true, completion: nil)
        }.catch { error in
            SVProgressHUD.showError(withStatus: "")
            print("\(#file) \(#function) \(error)")
        }
    }

    private func localize() {
        self.cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        self.questionLabel.text = NSLocalizedString("DeadlineModeQuestion", comment: "")
    }

    private func colorize() {
        self.view.backgroundColor = .stepikAlertBackground
        self.questionLabel.textColor = .stepikSystemPrimaryText
        self.cancelButton.setTitleColor(.stepikPrimaryText, for: .normal)
    }

    private func updateCollectionLayout() {
        self.collectionView.invalidateIntrinsicContentSize()
        self.collectionView.layoutIfNeeded()
        (self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = modeButtonSize
        (self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing = 12
        (self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing = 12
        self.collectionView.invalidateIntrinsicContentSize()
        self.collectionView.layoutIfNeeded()
    }
}

extension PersonalDeadlinesModeSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.didSelectMode(mode: self.modes[indexPath.item])
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { self.modes.count }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PersonalDeadlineModeCollectionViewCell",
            for: indexPath
        ) as? PersonalDeadlineModeCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.setup(deadlineMode: self.modes[indexPath.item])

        return cell
    }
}
