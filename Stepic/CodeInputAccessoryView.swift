//
//  CodeInputAccessoryView.swift
//  Stepic
//
//  Created by Ostrenkiy on 18.07.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import SnapKit

class CodeInputAccessoryView: NibInitializableView {

    @IBOutlet weak var hideKeyboardImageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!

    var hideKeyboardAction: (() -> Void)?

    var buttons: [CodeInputAccessoryButtonData] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var size: CodeInputAccessorySize = .small

    override var nibName: String {
        return "CodeInputAccessoryView"
    }

    override func setupSubviews() {
        collectionView.register(UINib(nibName: "CodeInputAccessoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CodeInputAccessoryCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self

        let tapG = UITapGestureRecognizer(target: self, action: #selector(CodeInputAccessoryView.didTapHideKeyboardImageView(recognizer:)))
        hideKeyboardImageView.addGestureRecognizer(tapG)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        hideKeyboardImageView.translatesAutoresizingMaskIntoConstraints = false
    }

    @objc func didTapHideKeyboardImageView(recognizer: UIGestureRecognizer) {
        hideKeyboardAction?()
    }

    convenience init(frame: CGRect, buttons: [CodeInputAccessoryButtonData], size: CodeInputAccessorySize, hideKeyboardAction: @escaping () -> Void) {
        self.init(frame: frame)
        self.size = size
        self.hideKeyboardAction = hideKeyboardAction
        self.buttons = buttons
        self.snp.makeConstraints { $0.height.equalTo(size.realSizes.viewHeight) }
    }
}

extension CodeInputAccessoryView : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = CodeInputAccessoryCollectionViewCell.width(for: buttons[indexPath.item].title, size: size)
        return CGSize(width: width, height: collectionView.bounds.height)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        buttons[indexPath.item].action()
    }
}

extension CodeInputAccessoryView : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return buttons.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CodeInputAccessoryCollectionViewCell", for: indexPath) as? CodeInputAccessoryCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.initialize(text: buttons[indexPath.item].title, size: size)

        return cell
    }
}

struct CodeInputAccessoryButtonData {
    var title: String
    var action: () -> Void
    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}
