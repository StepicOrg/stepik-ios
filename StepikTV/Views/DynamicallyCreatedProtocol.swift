//
//  DynamicallyCreatedProtocol.swift
//  StepikTV
//
//  Created by Александр Пономарев on 27.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

protocol DynamicallyCreatedProtocol {
    
    static var size: CGSize { get }
    
    static var reuseIdentifier: String { get }
    
}
