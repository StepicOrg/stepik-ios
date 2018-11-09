//
// Created by Ivan Magda on 11/9/18.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import UIKit

protocol CourseInfoTabInfoBlockViewModelProtocol {
    var blockType: CourseInfoTabInfoBlockType { get }

    var image: UIImage? { get }
    var title: String { get }
}

extension CourseInfoTabInfoBlockViewModelProtocol {
    var image: UIImage? {
        return self.blockType.image
    }

    var title: String {
        return self.blockType.title
    }
}
