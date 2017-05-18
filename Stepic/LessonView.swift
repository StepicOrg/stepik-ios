//
//  LessonView.swift
//  Stepic
//
//  Created by Ostrenkiy on 18.05.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

protocol LessonView: class {
    func setRefreshing(refreshing: Bool)
    func updateTitle(title: String)
    func reload()
    func selectTab(index: Int, updatePage: Bool)
    var nItem: UINavigationItem { get }
    var pagerGestureRecognizer: UIPanGestureRecognizer? { get }
}
