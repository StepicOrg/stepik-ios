//
//  OpenedStoriesPageViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol OpenedStoriesViewProtocol: class {
    
}

class OpenedStoriesPageViewController: UIPageViewController, OpenedStoriesViewProtocol {
    
    var presenter: OpenedStoriesPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
    }
}

extension OpenedStoriesPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return presenter?.prevModule
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return presenter?.nextModule
    }
    
    
}
