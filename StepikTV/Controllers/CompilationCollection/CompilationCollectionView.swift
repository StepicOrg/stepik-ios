//
//  CompilationCollectionViewProtocol.swift
//  StepikTV
//
//  Created by Anton Kondrashov on 25/11/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol CompilationCollectionView: class {

    func setup(with rows: [CollectionRow])

    func update(rowWith index: Int)

}
