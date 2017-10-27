//
//  MajorCollectionViewContainerCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 24.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

class MajorCollectionViewContainerCell: UICollectionViewCell, DynamicallyCreatedProtocol, ContainerConfigurableProtocol {

    static var reuseIdentifier: String { get { return "MajorCollectionViewContainerCell" } }

    static var size: CGSize {
        get {
            let width = UIScreen.main.bounds.width
            return CGSize(width: width, height: 420.0)
        }
    }

    @IBOutlet var collectionView: UICollectionView!

    fileprivate var source: [CourseMock] = [CourseMock]()

    fileprivate let itemsType = type(of: LargeItemCell.self())

    func configure(with data: [CourseMock], title: String? = nil) {
        source = data
        collectionView.reloadData()
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] { return [collectionView] }

    override func awakeFromNib() {
        super.awakeFromNib()

        let nib = UINib(nibName: itemsType.nibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: itemsType.reuseIdentifier)

        collectionView.isScrollEnabled = false
    }
}

extension MajorCollectionViewContainerCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {

        if ((context.nextFocusedIndexPath != nil) && !collectionView.isScrollEnabled) {
            collectionView.scrollToItem(at: context.nextFocusedIndexPath!, at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        let cell = cell as? ItemConfigurableProtocol
        cell?.configure(with: source[indexPath.row])
    }
}

extension MajorCollectionViewContainerCell: UICollectionViewDataSource {

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

extension MajorCollectionViewContainerCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemsType.size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        let cvWidth = collectionView.frame.width
        let cellWidth = itemsType.size.width
        let inset: CGFloat = cvWidth * 0.5 - cellWidth * 0.5
        return UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
    }
}
