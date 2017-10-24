//
//  RectangularCollectionViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 25.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

enum ContentType {
    case Done, Undone
}

class RectangularCollectionViewController: UICollectionViewController {
    
    var content: ContentType? {
        willSet(newValue) {
            if newValue == .Done {
                model = Model.sharedReference.getDoneCourses()
                collectionView?.reloadData()
            } else {
                model = Model.sharedReference.getUndoneCourses()
                collectionView?.reloadData()
            }
        }
    }
    
    fileprivate var model: [Course] = [Course]()
    
    fileprivate let itemsType = type(of: RectangularItemCell.self())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: itemsType.nibName, bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: itemsType.reuseIdentifier)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return model.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: itemsType.reuseIdentifier, for: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if let cell = cell as? RectangularItemCell {
            cell.configure(with: model[indexPath.row])
        }
        
    }
    
}
