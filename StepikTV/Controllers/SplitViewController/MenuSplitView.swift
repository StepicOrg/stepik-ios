//
//  MenuSplitView.swift
//  StepikTV
//
//  Created by Александр Пономарев on 30.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

protocol MenuSplitView: class {

    func showMessageOver(_ message: String)

    func showMessageOver(_ message: String, buttonTitle: String, buttonAction: @escaping () -> Void)

    func hideMessageOver()
}
