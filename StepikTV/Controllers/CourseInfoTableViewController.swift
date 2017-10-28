//
//  CourseInfoTableViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 27.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CourseInfoTableViewController: UICollectionViewController {
    
    private var course: Course?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    fileprivate func itemType(for indexPath: IndexPath) -> DynamicallyCreatedProtocol.Type {
        switch indexPath.section {
        case 0:
            return type(of: MainCourseInfoCell.self())
        default:
            return type(of: DetailsCourseInfoCell.self())
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = itemType(for: indexPath).reuseIdentifier
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellSize = itemType(for: indexPath).size
        return cellSize
    }
    
}
