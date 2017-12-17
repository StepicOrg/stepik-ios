//
//  CollectionRowViewCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 12.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CollectionRowViewCell: UICollectionViewCell {

    var dataCount: Int { return 0 }
    var cellSize: CGSize { return CGSize() }

    func getCell(for indexPath: IndexPath) -> UICollectionViewCell { return UICollectionViewCell() }

    func configure(cell: UICollectionViewCell, for indexPath: IndexPath) {}

    override func prepareForReuse() {
        // 
    }
}

extension CollectionRowViewCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        configure(cell: cell, for: indexPath)
    }
}

extension CollectionRowViewCell: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataCount
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return getCell(for: indexPath)
    }
}

extension CollectionRowViewCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}
