//
//  CourseTagsView.swift
//  Stepic
//
//  Created by Ostrenkiy on 21.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class CourseTagsView: NibInitializableView {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var tags: [CourseTag] = []
    
    var tagSelectedAction: ((CourseTag) -> Void)?
    
    var language: ContentLanguage = ContentLanguage.sharedContentLanguage {
        didSet {
            //TODO: check if selection needs to be updated here
            collectionView.reloadData()
        }
    }
    
    override func setupSubviews() {
        collectionView.register(UINib(nibName: "CourseTagsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CourseTagsCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        flowLayout.estimatedItemSize = CGSize(width: 80, height: 40)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
    }
    
    override var nibName: String {
        return "CourseTagsView"
    }
}

extension CourseTagsView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tagSelectedAction?(tags[indexPath.item])
    }
}

extension CourseTagsView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContentLanguageCollectionViewCell", for: indexPath) as? CourseTagCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.tagLabel.text = tags[indexPath.item].titleForLanguage[language]
        return cell
    }
}
