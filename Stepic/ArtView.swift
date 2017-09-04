//
//  ArtView.swift
//  Stepic
//
//  Created by Ostrenkiy on 04.09.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class ArtView: UIView {

    @IBOutlet weak var artImageView: NoIntrinsicSizeImageView!
    @IBOutlet weak var artImageViewWidth: NSLayoutConstraint!

    var art: UIImage? {
        didSet {
            artImageView.image = art
        }
    }

    var width: CGFloat = 0 {
        didSet {
            artImageViewWidth.constant = width - 48
        }
    }
    
    private func initialize() {
        artImageView.image = art
    }

    private var view: UIView!

    private func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        initialize()
    }

    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ArtView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }

    override init(frame: CGRect) {
        // 1. setup any properties here

        // 2. call super.init(frame:)
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here

        // 2. call super.init(coder:)
        super.init(coder: aDecoder)

        // 3. Setup view from .xib file
        setup()
    }
}
