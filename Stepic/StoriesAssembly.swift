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
    func buildModule() -> UIViewController {
        let vc = StoriesViewController()
        vc.presenter = StoriesPresenter(view: vc, storyTemplatesAPI: StoryTemplatesAPI())
        return vc
    }
}
