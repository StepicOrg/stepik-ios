//
//  TopicsCollectionViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 27/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class TopicsCollectionViewController: UICollectionViewController {
    private static let cellReuseIdentifier = String(describing: TopicsCollectionCell.self)
    private static let reuseIdentifier = String(describing: TopicsSectionCollectionViewCell.self)

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView?.backgroundColor = .white
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.alwaysBounceVertical = true

        let cellNib = UINib(nibName: TopicsCollectionViewController.cellReuseIdentifier, bundle: nil)
        collectionView?.register(
            cellNib,
            forCellWithReuseIdentifier: TopicsCollectionViewController.cellReuseIdentifier
        )
        let sectionNib = UINib(nibName: TopicsCollectionViewController.reuseIdentifier, bundle: nil)
        collectionView?.register(
            sectionNib,
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: TopicsCollectionViewController.reuseIdentifier
        )
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TopicsCollectionViewController.cellReuseIdentifier,
            for: indexPath
        ) as! TopicsCollectionCell

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionElementKindSectionHeader else {
            return UICollectionReusableView()
        }

        let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TopicsCollectionViewController.reuseIdentifier,
            for: indexPath
        ) as! TopicsSectionCollectionViewCell

        view.titleLabel.text = "Section \(indexPath.section + 1)".uppercased()
        view.actionButton.setTitle(NSLocalizedString("See All", comment: ""), for: .normal)

        return view
    }

    // MARK: UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(#function): \(indexPath)")
    }

}

extension TopicsCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 240)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: 54)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == numberOfSections(in: collectionView) - 1 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        }

        return .zero
    }
}
