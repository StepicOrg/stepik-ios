//
//  LoadingPaginationView.swift
//  Stepic
//
//  Created by Ostrenkiy on 12.04.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation

class LoadingPaginationView: NibInitializableView {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIButton!

    @IBAction func refreshPressed(_ sender: UIButton) {
        refreshAction?()
    }

    override var nibName: String {
        return "LoadingPaginationView"
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

    override func setupSubviews() {
        activityIndicator.color = UIColor.mainDark
    }
}
