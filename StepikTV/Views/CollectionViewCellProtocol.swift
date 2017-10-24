//
//  CollectionViewCellProtocol.swift
//  StepikTV
//
//  Created by Александр Пономарев on 24.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

protocol CollectionViewCellProtocol {
    
    static var size: CGSize { get }
    
    static var reuseIdentifier: String { get }
    
}
