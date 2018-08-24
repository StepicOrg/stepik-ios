//
//  StoriesAssembly.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 06.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation
import UIKit

class StoriesAssembly: Assembly {

    weak var refreshDelegate: StoriesRefreshDelegate?

    init(refreshDelegate: StoriesRefreshDelegate?) {
        self.refreshDelegate = refreshDelegate
    }

    func makeModule() -> UIViewController {
        let vc = StoriesViewController()
        vc.presenter = StoriesPresenter(view: vc, storyTemplatesAPI: StoryTemplatesAPI(), refreshDelegate: refreshDelegate)
        return vc
    }
}
