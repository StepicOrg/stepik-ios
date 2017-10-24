//
//  NarrowCollectionViewContainerCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 24.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

class NarrowCollectionViewContainerCell: UICollectionViewCell, CollectionViewCellProtocol, CollectionViewContainerCellProtocol  {
    
    static var reuseIdentifier: String { get { return "NarrowCollectionViewContainerCell" } }
    
    static var size: CGSize { get { return CGSize(width: UIScreen.main.bounds.width, height: 280.0) } }
    
    @IBOutlet weak var titleLabel: UILabel?
    
    @IBOutlet var collectionView: UICollectionView!
    
    fileprivate var source: [UIImage] = [UIImage]()
    
    fileprivate let itemsType = type(of: SmallItemCell.self())
    
    func configure(with data: [UIImage], title: String? = nil) {
        source = data
        titleLabel?.text = title
        collectionView.reloadData()
    }
    
    override var preferredFocusEnvironments: [UIFocusEnvironment] { return [collectionView] }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let nib = UINib(nibName: itemsType.nibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: itemsType.reuseIdentifier)
    }
}

extension NarrowCollectionViewContainerCell: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return source.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: itemsType.reuseIdentifier, for: indexPath)
    }
}

extension NarrowCollectionViewContainerCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemsType.size
    }
}
