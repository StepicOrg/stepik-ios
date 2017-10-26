//
//  HomeScreenPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 25.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol HomeScreenView: class {
    func presentBlocks(blocks: [CourseListBlock])
}

class HomeScreenPresenter {
    weak var view: HomeScreenView?
    init(view: HomeScreenView) {
        self.view = view
    }

    func getBlocks() {
        view?.presentBlocks(blocks: blocks)
    }

    let blocks = [
        CourseListBlock(listType: .enrolled, horizontalLimit: 6, title: "Enrolled", colorMode: .dark),
        CourseListBlock(listType: .popular, horizontalLimit: 6, title: "Popular", colorMode: .light)
    ]
}

struct CourseListBlock {
    let listType: CourseListType
    let horizontalLimit: Int
    let title: String
    let colorMode: CourseListColorMode

    init(listType: CourseListType, horizontalLimit: Int, title: String, colorMode: CourseListColorMode) {
        self.listType = listType
        self.horizontalLimit = horizontalLimit
        self.title = title
        self.colorMode = colorMode
    }
}
