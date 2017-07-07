//
//  AdaptiveOnboardingViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 07.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class AdaptiveOnboardingViewController: UIViewController, AdaptiveOnboardingView {
    var presenter: AdaptiveOnboardingPresenter?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        presenter = AdaptiveOnboardingPresenter(view: self)
    }
}
