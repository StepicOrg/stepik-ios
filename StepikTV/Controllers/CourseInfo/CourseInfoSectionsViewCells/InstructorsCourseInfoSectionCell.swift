//
//  InstructorsCourseInfoSectionCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 17.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class InstructorsCourseInfoSectionCell: CollectionRowViewCell, CourseInfoSectionViewProtocol {
    static var nibName: String { return "InstructorsCourseInfoSectionCell" }
    static var reuseIdentifier: String { return "InstructorsCourseInfoSectionCell" }
    static var size: CGSize { return CGSize(width: UIScreen.main.bounds.width, height: 100.0) }

    @IBOutlet var title: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var backSizeLabel: UILabel!
    @IBOutlet var widthConstraint: NSLayoutConstraint!

    var data: [ItemViewData] = []

    func setup(with section: CourseInfoSection) {
        title.text = section.title

        // Fix autolayout self-sizing cell bag
        backSizeLabel.text = "\n\n\n\n\n\n\n\n\n"

        switch section.contentType {
        case let .instructors(items: items):
            self.data = items
            collectionView.reloadData()
        default:
            fatalError("Sections data and view dependencies fails")
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        widthConstraint.constant = InstructorsCourseInfoSectionCell.size.width

        collectionView.delegate = self
        collectionView.dataSource = self

        let nib = UINib(nibName: InstructorItemCell.nibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: InstructorItemCell.reuseIdentifier)
    }

    override var dataCount: Int { return data.count }
    override var cellSize: CGSize { return InstructorItemCell.size }

    override func getCell(for indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: InstructorItemCell.reuseIdentifier, for: indexPath)
    }

    override func configure(cell: UICollectionViewCell, for indexPath: IndexPath) {
        guard let cell = cell as? InstructorItemCell else { return }
        cell.setup(with: data[indexPath.item])
    }
}
