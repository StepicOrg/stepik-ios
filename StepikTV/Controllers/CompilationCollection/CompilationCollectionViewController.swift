//
//  CompilationViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 19.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//
import UIKit

class CompilationCollectionViewController: UICollectionViewController {

    var presenter: CompilationCollectionPresenter?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.presenter = CompilationCollectionPresenter(view: self, courseListsAPI: CourseListsAPI(), courseListsCache: CourseListsCache())
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.refresh()

        guard let cv = collectionView, let layout = cv.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        var nib = UINib(nibName: "MajorCollectionRowViewCell", bundle: nil)
        cv.register(nib, forCellWithReuseIdentifier: MajorCollectionRowViewCell.reuseIdentifier)

        nib = UINib(nibName: "NarrowCollectionRowViewCell", bundle: nil)
        cv.register(nib, forCellWithReuseIdentifier: NarrowCollectionRowViewCell.reuseIdentifier)

        nib = UINib(nibName: "RegularCollectionRowViewCell", bundle: nil)
        cv.register(nib, forCellWithReuseIdentifier: RegularCollectionRowViewCell.reuseIdentifier)

        let minimumEdgePadding = CGFloat(90.0)
        cv.contentInset.top = CGFloat(-120)
        cv.contentInset.bottom = minimumEdgePadding - layout.sectionInset.bottom
    }

    var collectionRows: [CollectionRow] = []

    // MARK: UICollectionViewDataSource methods
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return collectionRows.count
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let identifier = collectionRows[indexPath.section].type.viewClass.reuseIdentifier
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }

    // MARK: UICollectionViewDelegate methods
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        guard let cell = cell as? CollectionRowView else { return }
        let row = collectionRows[indexPath.section]
      
        cell.setup(with: row.data, title: row.title)
    }

    override func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension CompilationCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let size = collectionRows[indexPath.section].type.viewClass.size
        return size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0, bottom: 20.0, right: 0.0)
    }
}

extension CompilationCollectionViewController: CompilationCollectionView {

    func setup(with rows: [CollectionRow]) {
        self.collectionRows = rows
        collectionView?.reloadData()
    }

    func update(rowWith index: Int) {
        let indexPath = IndexPath(item: 0, section: index)
        collectionView?.reloadItems(at: [indexPath])
    }
}
