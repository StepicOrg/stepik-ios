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
    @IBOutlet weak var titleLabel: StepikLabel!

    var tags: [CourseTag] = []

    var tagSelectedAction: ((CourseTag) -> Void)?

    var language: ContentLanguage = ContentLanguage.sharedContentLanguage {
        didSet {
            //TODO: check if selection needs to be updated here
            collectionView.reloadData()
        }
    }

    override func setupSubviews() {
        collectionView.register(UINib(nibName: "CourseTagCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CourseTagCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        flowLayout.setEstimatedItemSize(CGSize(width: 80.0, height: 40.0), fallbackOnPlus: CGSize(width: 205.0, height: 40.0))

        //estimatedItemSize = CGSize(width: 80, height: 40)
        flowLayout.minimumInteritemSpacing = 20
        flowLayout.minimumLineSpacing = 20
        titleLabel.colorMode = .gray
        titleLabel.text = NSLocalizedString("TrendingTopics", comment: "")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }

    override var nibName: String {
        return "CourseTagsView"
    }
}

extension CourseTagsView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tagSelectedAction?(tags[indexPath.item])
        collectionView.deselectItem(at: indexPath, animated: true)
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CourseTagCollectionViewCell", for: indexPath) as? CourseTagCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.tagLabel.text = tags[indexPath.item].titleForLanguage[language]
        return cell
    }
}
