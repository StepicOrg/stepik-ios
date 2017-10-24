//
//  Model.swift
//  StepikTV
//
//  Created by Александр Пономарев on 24.10.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import UIKit

class Model {
    
    private let titles = [nil, "Предметы", "Лучшее", "Прочее","","","",""]
    
    private let source: [[UIImage]] = {
        var outer = [[UIImage]]()
        for i in 1...8 {
            var inner = [UIImage](repeatElement(UIImage(), count: 8))
            outer.append(inner)
        }
        return outer
    }()
    
    func getOuter() -> [[UIImage]] {
        return source
    }
    
    func getInner(at index: Int) -> [UIImage] {
        return source[index]
    }
    
    func getTitles(at index: Int) -> String? {
        return titles[index]
    }
    
}

