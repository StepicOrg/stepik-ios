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
    
    static let sharedReference = Model()
    
    private let titles = [nil, "Предметы", "Новые курсы", "Editor's choice", "Современная грамотность","Умный досуг","Курсы для программистов","Математика для программистов"]
    
    private var source: [[Course]] = [[Course]]()
    
    init() {
        for i in titles {
            var inner = [Course]()
            let index = titles.index(where: {$0 == i})
            for j in 1...(10 - index!) {
                let course = Course(image: UIImage(), name: "\(i ?? "nil")#\(j)", host: "Яндекс")
                inner.append(course)
            }
            source.append(inner)
        }
    }
    
    func getOuter() -> [[Course]] {
        return source
    }
    
    func getInner(at index: Int) -> [Course] {
        return source[index]
    }
    
    func getTitles(at index: Int) -> String? {
        return titles[index]
    }
    
    func getUndoneCourses() -> [Course] {
        return source[5]
    }
    
    func getDoneCourses() -> [Course] {
        return source[2]
    }
}

struct Course {
    
    var image: UIImage
    var name: String
    var host: String
    
    init(image: UIImage, name: String, host: String) {
        self.image = image
        self.name = name
        self.host = host
    }
    
}

