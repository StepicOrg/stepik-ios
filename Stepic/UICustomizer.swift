//
//  UICustomizer.swift
//  Stepic
//
//  Created by Alexander Karpov on 18.09.15.
//  Copyright (c) 2015 Alex Karpov. All rights reserved.
//

import UIKit
import DownloadButton

class UICustomizer: NSObject {
    static var sharedCustomizer = UICustomizer()
    fileprivate override init() {}

    func setCustomDownloadButton(_ button: PKDownloadButton, white: Bool = false) {
        button.startDownloadButton?.cleanDefaultAppearance()
        button.startDownloadButton?.setBackgroundImage(white ? Images.downloadFromCloudWhite : Images.downloadFromCloud, for: UIControlState())

        if white {
            button.stopDownloadButton?.tintColor = UIColor.white
        }

        button.downloadedButton?.cleanDefaultAppearance()
        button.downloadedButton?.setBackgroundImage(white ? Images.deleteWhite : Images.delete, for: UIControlState())
    }
}
