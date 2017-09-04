//
//  NoIntrinsicSizeImageView.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class NoIntrinsicSizeImageView: UIImageView {
    override var intrinsicContentSize: CGSize {
        return CGSize.zero
    }
}
