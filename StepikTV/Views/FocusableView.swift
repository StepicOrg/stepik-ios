//
//  ContentView.swift
//  StepikTV
//
//  Created by Александр Пономарев on 24.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class FocusableView: UIView {

    override var canBecomeFocused: Bool { return true }
}

class FocusableLabel: UILabel {

    override var canBecomeFocused: Bool { return true }
}
