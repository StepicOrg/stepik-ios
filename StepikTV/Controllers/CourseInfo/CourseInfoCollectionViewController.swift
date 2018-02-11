//
//  CourseInfoTableViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 27.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CourseInfoCollectionViewController: UICollectionViewController {

    fileprivate var loadingView: TVLoadingView?

    override func viewDidLoad() {
        super.viewDidLoad()

        let mainNib = UINib(nibName: MainCourseInfoSectionCell.nibName, bundle: nil)
        collectionView?.register(mainNib, forCellWithReuseIdentifier: MainCourseInfoSectionCell.reuseIdentifier)

        let detailsNib = UINib(nibName: DetailsCourseInfoSectionCell.nibName, bundle: nil)
        collectionView?.register(detailsNib, forCellWithReuseIdentifier: DetailsCourseInfoSectionCell.reuseIdentifier)

        let instructorsNib = UINib(nibName: InstructorsCourseInfoSectionCell.nibName, bundle: nil)
        collectionView?.register(instructorsNib, forCellWithReuseIdentifier: InstructorsCourseInfoSectionCell.reuseIdentifier)
    }

    var presenter: CourseInfoPresenter?
    var sections: [CourseInfoSection] = []

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

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? CourseInfoSectionViewProtocol else { return }
        cell.setup(with: sections[indexPath.section])
    }
}

extension CourseInfoCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = UIScreen.main.bounds.width
        let height = sections[indexPath.section].contentType.viewClass.getHeightForCell(section: sections[indexPath.section], width: width)

        return CGSize(width: width, height: height)
    }
}

extension CourseInfoCollectionViewController: CourseInfoView {

    func provide(sections: [CourseInfoSection]) {
        self.sections = sections
        collectionView?.reloadData()
    }

    func showLoading(title: String) {
        loadingView = TVLoadingView(frame: self.view.frame)
        loadingView!.setup(title: title)

        view.addSubview(loadingView!)
    }

    func hideLoading() {
        loadingView?.purge()
        loadingView?.removeFromSuperview()
    }

    func dismissOnUnsubscribe() {
        self.dismiss(animated: true, completion: nil)
    }
}
