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

    private let titles = [nil, "Предметы", "Новые курсы", "Editor's choice", "Современная грамотность", "Умный досуг", "Курсы для программистов", "Математика для программистов"]

    private var source: [[CourseMock]] = [[CourseMock]]()

    init() {
        for i in titles {
            var inner = [CourseMock]()
            let index = titles.index(where: {$0 == i})
            for j in 1...(10 - index!) {
                let course = CourseMock(image: UIImage(), name: "\(i ?? "nil")#\(j)", host: "Яндекс")
                inner.append(course)
            }
            source.append(inner)
        }
    }

    func getOuter() -> [[CourseMock]] {
        return source
    }

    func getInner(at index: Int) -> [CourseMock] {
        return source[index]
    }

    func getTitles(at index: Int) -> String? {
        return titles[index]
    }

    func getUndoneCourses() -> [CourseMock] {
        return source[5]
    }

    func getDoneCourses() -> [CourseMock] {
        return source[2]
    }

    func getCurrentCourse() -> CourseMock {
        return CourseMock(image: UIImage(), name: "Основы статистики", host: "")
    }

}

struct CourseMock {

    var image: UIImage
    var name: String
    var host: String

    init(image: UIImage, name: String, host: String) {
        self.image = image
        self.name = name
        self.host = host

    }

    let paragraphs = [Paragraph(name: "Введение", lessons: ["Приветсвие", "Введение"]),
                      Paragraph(name: "Сравнение средних", lessons: ["T-распределение", "Сравнение двух средних", "Проверка распределения на нормальность и проверка многострочных имен", "Однофакторный дисперсионный анализ"]),
                      Paragraph(name: "Корреляция и регрессия", lessons: ["Корреляция", "Регрессия при нормальном распределении"])]
}

struct Paragraph {

    var name: String

    var lessons: [String]

    init(name: String, lessons: [String]) {
        self.name = name
        self.lessons = lessons
    }

}
