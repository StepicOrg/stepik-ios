//
//  NarrowCollectionViewContainerCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 24.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

class NarrowCollectionViewContainerCell: UICollectionViewCell, DynamicallyCreatedProtocol, ContainerConfigurableProtocol {

    static var reuseIdentifier: String { get { return "NarrowCollectionViewContainerCell" } }

    static var size: CGSize { get { return CGSize(width: UIScreen.main.bounds.width, height: 280.0) } }

    @IBOutlet var titleLabel: UILabel?

    @IBOutlet var collectionView: UICollectionView!

    fileprivate var source: [CourseMock] = [CourseMock]()

    fileprivate let itemsType = type(of: SmallItemCell.self())

    func configure(with data: [CourseMock], title: String? = nil) {
        source = data
        titleLabel?.text = title
        collectionView.reloadData()
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] { return [collectionView] }

    override func awakeFromNib() {
        super.awakeFromNib()

        let nib = UINib(nibName: itemsType.nibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: itemsType.reuseIdentifier)
    }
}

extension NarrowCollectionViewContainerCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        let cell = cell as? ItemConfigurableProtocol
        cell?.configure(with: source[indexPath.row])
    }

}

extension NarrowCollectionViewContainerCell: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return source.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: itemsType.reuseIdentifier, for: indexPath)
    }
}

extension NarrowCollectionViewContainerCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemsType.size
    }
}
