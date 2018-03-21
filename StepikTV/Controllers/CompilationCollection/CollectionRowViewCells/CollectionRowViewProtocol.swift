//
//  CollectionRowViewProtocol.swift
//  StepikTV
//
//  Created by Александр Пономарев on 11.12.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

protocol CollectionRowViewProtocol {

    static var size: CGSize { get }
    static var reuseIdentifier: String { get }

    func setup(with data: [ItemViewData], title: String?)
}
