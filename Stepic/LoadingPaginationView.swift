//
//  LoadingPaginationView.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class LoadingPaginationView: UIView {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIButton!

    @IBAction func refreshPressed(_ sender: UIButton) {
        refreshAction?()
    }

    var refreshAction : (() -> Void)?

    func setLoading() {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        refreshButton.isHidden = true
    }

    func setError() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        refreshButton.isHidden = false
    }

    fileprivate var view: UIView!

    fileprivate func setup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }

    fileprivate func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "LoadingPaginationView", bundle: bundle)
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
