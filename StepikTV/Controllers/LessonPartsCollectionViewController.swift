//
//  LessonPartsCollectionViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 07.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import AVKit

class LessonPartsCollectionViewController: UICollectionViewController {

    var lesson = LessonMock()

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: LessonPartItemCell.nibName, bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: LessonPartItemCell.reuseIdentifier)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return lesson.parts.count
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
            cell.configure(with: lesson.parts[indexPath.section], index: indexPath.section + 1)
        }
    }

}

extension LessonPartsCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellSize = LessonPartItemCell.size
        return cellSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 24, bottom: 0, right: 24)
    }
}

extension LessonPartsCollectionViewController: LessonPartPresentContentDelegate {

    func loadContentIn(controller: UIViewController, completion: @escaping () -> Void) {
        self.present(controller, animated: true, completion: completion)
    }
}
