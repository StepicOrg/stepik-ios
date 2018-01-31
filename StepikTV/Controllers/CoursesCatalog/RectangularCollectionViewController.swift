//
//  RectangularCollectionViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 25.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class RectangularCollectionViewController: UICollectionViewController {

    fileprivate var loadingView: TVLoadingView?

    // Set for correcting show loading
    var width: CGFloat?

    var sectionCourses: [ItemViewData] = [] {
        didSet { collectionView?.reloadData() }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: RectangularItemCell.nibName, bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: RectangularItemCell.reuseIdentifier)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionCourses.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: RectangularItemCell.reuseIdentifier, for: indexPath)
    }

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        guard let cell = cell as? RectangularItemCell else { return }
        cell.setup(with: sectionCourses[indexPath.row])
    }
}

extension RectangularCollectionViewController: DetailCatalogView {

    func provide(items: [ItemViewData]) {
        sectionCourses = items
    }

    func showLoading(isVisible: Bool) {

        guard isVisible else {
            loadingView?.purge()
            loadingView?.removeFromSuperview()
            loadingView = nil
            return
        }

        guard let width = width else { return }
        let rect = CGRect(x: 0, y: 0, width: width, height: UIScreen.main.bounds.height)

        guard let _ = loadingView else {

            loadingView = TVLoadingView(frame: rect, color: .gray)
            loadingView!.setup()

            self.view.addSubview(loadingView!)
            return
        }
    }

    func update() {
        collectionView?.reloadData()
    }
}
