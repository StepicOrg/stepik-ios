//
//  ContentLanguagesView.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class ContentLanguagesView: NibInitializableView {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!

    @IBOutlet weak var titleLabel: StepikLabel!

    var languages: [ContentLanguage] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    var currentlySelectedIndexPath: IndexPath?

    var initialLanguage: ContentLanguage?
    var languageSelectedAction: ((ContentLanguage) -> Void)?

    override var nibName: String {
        return "ContentLanguagesView"
    }

    override func setupSubviews() {
        collectionView.register(UINib(nibName: "ContentLanguageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ContentLanguageCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        flowLayout.itemSize = CGSize(width: 46, height: 40)
        flowLayout.minimumInteritemSpacing = 12
        flowLayout.minimumLineSpacing = 12
        titleLabel.colorMode = .gray
        titleLabel.text = NSLocalizedString("ChooseSearchLanguage", comment: "")
    }
}

extension ContentLanguagesView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath != currentlySelectedIndexPath {
            if let currentlySelectedIndexPath = currentlySelectedIndexPath {
                collectionView.deselectItem(at: currentlySelectedIndexPath, animated: false)
                (collectionView.cellForItem(at: currentlySelectedIndexPath) as? ContentLanguageCollectionViewCell)?.isSelected = false
            }
            currentlySelectedIndexPath = indexPath
            languageSelectedAction?(languages[indexPath.item])
        }
    }
}

extension ContentLanguagesView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return languages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentLanguageCollectionViewCell", for: indexPath) as? ContentLanguageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.language = languages[indexPath.item].displayingString
        if languages[indexPath.item] == initialLanguage {
            cell.isSelected = true
            currentlySelectedIndexPath = indexPath
        }
        return cell
    }
}
