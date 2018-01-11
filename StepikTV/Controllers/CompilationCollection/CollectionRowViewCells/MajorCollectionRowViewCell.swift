//
//  MajorCollectionRowViewCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 10.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class MajorCollectionRowViewCell: CollectionRowViewCell, CollectionRowViewProtocol {
    static var reuseIdentifier: String { return "MajorCollectionRowViewCell" }
    static var size: CGSize { return CGSize(width: UIScreen.main.bounds.width, height: 420.0) }

    @IBOutlet var collectionView: UICollectionView!

    var data: [ItemViewData] = []

    func setup(with data: [ItemViewData], title: String? = nil) {
        self.data = data
        collectionView.reloadData()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.delegate = self
        collectionView.dataSource = self

        let nib = UINib(nibName: MajorItemCell.nibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: MajorItemCell.reuseIdentifier)
        collectionView.isScrollEnabled = false
    }

    // MARK: Overriding CollectionRowViewCell to construct collectionView

    override var dataCount: Int { return data.count }
    override var cellSize: CGSize { return MajorItemCell.size }

    override func getCell(for indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: MajorItemCell.reuseIdentifier, for: indexPath)
    }

    override func configure(cell: UICollectionViewCell, for indexPath: IndexPath) {
        guard let cell = cell as? MajorItemCell else { return }
        cell.setup(with: data[indexPath.item])
    }

    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {

        guard let nextIndex = context.nextFocusedIndexPath, !collectionView.isScrollEnabled else { return }
        collectionView.scrollToItem(at: nextIndex, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let cvWidth = collectionView.frame.width
        let cellWidth = MajorItemCell.size.width
        let inset: CGFloat = cvWidth * 0.5 - cellWidth * 0.5
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}
