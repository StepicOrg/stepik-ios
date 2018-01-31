//
//  LessonPartsCollectionViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 07.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class LessonStepsCollectionViewController: UICollectionViewController {

    fileprivate var loadingView: TVLoadingView?

    var presenter: LessonContentPresenter?

    var steps: [StepViewData] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: StepItemCell.nibName, bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: StepItemCell.reuseIdentifier)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return steps.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = StepItemCell.reuseIdentifier
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }

    // MARK: UICollectionViewDelegate methods

    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        guard let cell = cell as? StepItemCell else { return }
        cell.setup(with: steps[indexPath.section], index: indexPath.section + 1)
    }

}

extension LessonStepsCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let cellSize = StepItemCell.size
        return cellSize
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 24, bottom: 0, right: 24)
    }
}

extension LessonStepsCollectionViewController: LessonContentView {

    func showLoading() {
        loadingView = TVLoadingView(frame: self.view.bounds, color: .darkGray)
        loadingView!.setup()

        view.addSubview(loadingView!)
    }

    func hideLoading() {
        loadingView?.purge()

        loadingView?.removeFromSuperview()
    }

    func provide(steps: [StepViewData]) {
        self.steps = steps
        self.collectionView?.reloadData()
    }

    func update(at index: Int) {
        guard index < steps.count else { print("index > steps.count"); return }
        steps[index].isPassed = true

        let indexPath = IndexPath(item: 0, section: index)
        self.collectionView?.reloadItems(at: [indexPath])
    }
}
