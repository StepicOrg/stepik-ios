//
//  PlaceholderViewDataSource.swift
//  OstrenkiyPlaceholderView
//
//  Created by Alexander Karpov on 02.02.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

protocol PlaceholderViewDataSource {
    func placeholderImage() -> UIImage?
    func placeholderStyle() -> PlaceholderStyle
    func placeholderTitle() -> String?
    func placeholderDescription() -> String?
    func placeholderButtonTitle() -> String?
}
