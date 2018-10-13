//
//  UICollectionViewExtensions.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 20.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

extension UICollectionView {
    func register<T: UICollectionViewCell>(cellClass: T.Type) where T: Reusable {
        print(cellClass.defaultReuseIdentifier)
        register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }

    func register<T: UICollectionViewCell>(
        cellClass: T.Type
    ) where T: Reusable, T: NibLoadable {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)

        register(nib, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }

    func register<T: UICollectionReusableView>(
        viewClass: T.Type,
        forSupplementaryViewOfKind kind: String
    ) where T: Reusable {
        register(
            T.self,
            forSupplementaryViewOfKind: kind,
            withReuseIdentifier: T.defaultReuseIdentifier
        )
    }

    func register<T: UICollectionReusableView>(
        viewClass: T.Type,
        forSupplementaryViewOfKind kind: String
    ) where T: Reusable, T: NibLoadable {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)

        register(
            nib,
            forSupplementaryViewOfKind: kind,
            withReuseIdentifier: T.defaultReuseIdentifier
        )
    }

    func dequeueReusableCell<T: UICollectionViewCell>(
        for indexPath: IndexPath
    ) -> T where T: Reusable {
        guard let cell = dequeueReusableCell(
            withReuseIdentifier: T.defaultReuseIdentifier,
            for: indexPath
        ) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }

        return cell
    }

    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(
        ofKind kind: String,
        for indexPath: IndexPath
    ) -> T where T: Reusable {
        guard let view = dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: T.defaultReuseIdentifier,
            for: indexPath
        ) as? T else {
            fatalError("Could not dequeue supplementary view" +
                "with identifier: \(T.defaultReuseIdentifier)"
            )
        }

        return view
    }
}
