//
//  NarrowCollectionRowViewCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 11.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class NarrowCollectionRowViewCell: CollectionRowViewCell, CollectionRowViewProtocol {

    static var reuseIdentifier: String { return "NarrowCollectionRowViewCell" }
    static var size: CGSize { return CGSize(width: UIScreen.main.bounds.width, height: 280.0) }

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var title: UILabel!

    var data: [ItemViewData] = []

    func setup(with data: [ItemViewData], title: String? = nil) {
        self.data = data
        self.title.text = title
        collectionView.reloadData()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.delegate = self
        collectionView.dataSource = self

        let nib = UINib(nibName: NarrowItemCell.nibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: NarrowItemCell.reuseIdentifier)
    }

    // MARK: Overriding CollectionRowViewCell to construct collectionView

    override var dataCount: Int { return data.count }
    override var cellSize: CGSize { return NarrowItemCell.size }

    override func getCell(for indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: NarrowItemCell.reuseIdentifier, for: indexPath)
    }

    override func configure(cell: UICollectionViewCell, for indexPath: IndexPath) {
        guard let cell = cell as? NarrowItemCell else { return }
        cell.setup(with: data[indexPath.item])
    }
}
