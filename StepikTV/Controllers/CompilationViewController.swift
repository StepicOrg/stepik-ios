//
//  CompilationViewController.swift
//  StepikTV
//
//  Created by Александр Пономарев on 19.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//
import UIKit

class CompilationViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let collectionView = collectionView, let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        
        let minimumEdgePadding = CGFloat(90.0)
        collectionView.contentInset.top = CGFloat(-120)
        collectionView.contentInset.bottom = minimumEdgePadding - layout.sectionInset.bottom
    }
    
    fileprivate func itemType(for indexPath: IndexPath) -> DynamicallyCreatedProtocol.Type {
        switch indexPath.section {
        case 0:
            return type(of: MajorCollectionViewContainerCell.self())
        case 1:
            return type(of: NarrowCollectionViewContainerCell.self())
        default:
            return type(of: RegularCollectionViewContainerCell.self())
        }
    }
    
    //MARK: UICollectionViewDataSource methods
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Model.sharedReference.getOuter().count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = itemType(for: indexPath).reuseIdentifier
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    
    //MARK: UICollectionViewDelegate methods
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let sectionData = Model.sharedReference.getInner(at: indexPath.section)
        let sectionTitle = Model.sharedReference.getTitles(at: indexPath.section)
        
        if let cell = cell as? ContainerConfigurableProtocol {
            cell.configure(with: sectionData, title: sectionTitle)
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension CompilationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellSize = itemType(for: indexPath).size
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 0, 20.0, 0.0)
    }
    
}
