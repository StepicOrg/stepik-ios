//
//  CourseInfoTableViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 27.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CourseInfoCollectionViewController: UICollectionViewController {

    var presenter: CourseInfoPresenter?

    var sections: [CourseInfoSection] = []

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = sections[indexPath.section].contentType.viewClass.reuseIdentifier
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }

    override func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {MainCourseInfoSectionCell.reuseIdentifier
        guard let cell = cell as? CourseInfoSectionView else { return }
        cell.setup(with: sections[indexPath.section])
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let size = sections[indexPath.section].contentType.viewClass.size
        return size
    }
}

extension CourseInfoCollectionViewController: CourseInfoView {

    func provide(sections: [CourseInfoSection]) {
        self.sections = sections
        collectionView?.reloadData()
    }
}
