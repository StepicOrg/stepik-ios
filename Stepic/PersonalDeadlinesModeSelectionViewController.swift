//
//  PersonalDeadlinesModeSelectionViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout
import SVProgressHUD

class PersonalDeadlinesModeSelectionViewController: UIViewController {

    @IBOutlet weak var questionLabel: StepikLabel!
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

        self.collectionView.register(UINib(nibName: "PersonalDeadlineModeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PersonalDeadlineModeCollectionViewCell")

        collectionView.delegate = self
        collectionView.dataSource = self
        questionLabel.constrainWidth("\(UIScreen.main.bounds.width - 80)")
        localize()
        AnalyticsReporter.reportEvent(AnalyticsEvents.PersonalDeadlines.Mode.opened)
    }

    private func localize() {
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        questionLabel.text = NSLocalizedString("DeadlineModeQuestion", comment: "")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutSubviews()
        collectionView.constrainHeight("\(modeButtonSize.height)")
        updateCollectionLayout()
    }

    private func updateCollectionLayout() {
        collectionView.invalidateIntrinsicContentSize()
        collectionView.layoutIfNeeded()
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = modeButtonSize
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing = 12
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing = 12
        collectionView.invalidateIntrinsicContentSize()
        collectionView.layoutIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateCollectionLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        AnalyticsReporter.reportEvent(AnalyticsEvents.PersonalDeadlines.Mode.closed)

    }

    func didSelectMode(mode: DeadlineMode) {
        guard let course = course else {
            self.dismiss(animated: true, completion: nil)
            return
        }

        AnalyticsReporter.reportEvent(AnalyticsEvents.PersonalDeadlines.Mode.chosen, parameters: ["hours": mode.getModeInfo().weeklyLoadHours])
        SVProgressHUD.show()
        PersonalDeadlineManager.shared.countDeadlines(for: course, mode: mode).then {
            () -> Void in
            SVProgressHUD.dismiss()
            self.onDeadlineSelected?()
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension PersonalDeadlinesModeSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectMode(mode: modes[indexPath.item])
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return modes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PersonalDeadlineModeCollectionViewCell", for: indexPath) as? PersonalDeadlineModeCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.setup(deadlineMode: modes[indexPath.item])
        return cell
    }
}
