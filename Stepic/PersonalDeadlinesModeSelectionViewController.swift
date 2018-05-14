//
//  PersonalDeadlinesModeSelectionViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.05.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout
class PersonalDeadlinesModeSelectionViewController: UIViewController {

    @IBOutlet weak var questionLabel: StepikLabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectButton: StepikButton!
    @IBOutlet weak var cancelButton: UIButton!

    let modes: [DeadlineMode] = [.hobby, .standard, .extreme]

    private var modeButtonSize: CGSize {
        let width = CGFloat(Int((collectionView.bounds.width - (CGFloat(modes.count) - 1) * 12) / 3))
        let height = width + 44
        return CGSize(width: width, height: height)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.collectionView.register(UINib(nibName: "PersonalDeadlineModeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PersonalDeadlineModeCollectionViewCell")

        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = modeButtonSize
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing = 12
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing = 12
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.constrainHeight("\(modeButtonSize.height)")
        questionLabel.constrainWidth("\(UIScreen.main.bounds.width - 80)")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = modeButtonSize
        collectionView.invalidateIntrinsicContentSize()
        collectionView.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil, completion: {
            [weak self]
            _ in
            guard let strongSelf = self else {
                return
            }
            (strongSelf.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize = strongSelf.modeButtonSize
            strongSelf.collectionView.invalidateIntrinsicContentSize()
            strongSelf.collectionView.layoutIfNeeded()
        })
    }
}

extension PersonalDeadlinesModeSelectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
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
