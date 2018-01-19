//
//  LessonPartsCollectionViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 07.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import AVKit

class LessonStepsCollectionViewController: UICollectionViewController {

    var presenter: LessonContentPresenter?

    var steps: [Step] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: LessonPartItemCell.nibName, bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: LessonPartItemCell.reuseIdentifier)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return steps.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = LessonPartItemCell.reuseIdentifier
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }

    // MARK: UICollectionViewDelegate methods

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if let cell = cell as? LessonPartItemCell {
            cell.delegate = self
            //cell.configure(with: steps[indexPath.section], index: indexPath.section + 1)
        }
    }

}

extension LessonStepsCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellSize = LessonPartItemCell.size
        return cellSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 24, bottom: 0, right: 24)
    }
}

extension LessonStepsCollectionViewController: LessonPartPresentContentDelegate {

    func loadLessonContent(with controller: UIViewController, completion: @escaping () -> Void) {
        self.present(controller, animated: true, completion: completion)
    }
}

extension LessonStepsCollectionViewController: LessonContentView {

}
