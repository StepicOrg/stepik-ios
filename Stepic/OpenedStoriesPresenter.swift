//
//  OpenedStoriesPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol OpenedStoriesPresenterProtocol: class {
    var nextModule: UIViewController? { get }
    var prevModule: UIViewController? { get }
}

class OpenedStoriesPresenter: OpenedStoriesPresenterProtocol {
    weak var view: OpenedStoriesViewProtocol?
    
    var nextModule: UIViewController?
    var prevModule: UIViewController?    
    
    init(view: OpenedStoriesViewProtocol) {
        self.view = view
    }
}
