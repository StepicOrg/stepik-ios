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

    weak var moduleOutput: StoriesOutputProtocol?

    init(output: StoriesOutputProtocol?) {
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let vc = StoriesViewController()
        let presenter = StoriesPresenter(view: vc, storyTemplatesAPI: StoryTemplatesAPI())
        presenter.moduleOutput = self.moduleOutput
        vc.presenter = presenter
        return vc
    }
}
