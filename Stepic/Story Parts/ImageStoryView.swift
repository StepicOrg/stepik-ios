//
//  ImageStoryView.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 03.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation
import UIKit
import Nuke
import SnapKit

class ImageStoryView: UIView, UIStoryViewProtocol {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var imagePath: String = ""
    var completion: (() -> Void)?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.isHidden = true
    }
    
    func startLoad() {
        if activityIndicator.isHidden != false {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
        guard let url = URL(string: imagePath) else { return }
        Nuke.loadImage(with: url, options: .shared, into: imageView) { [weak self] (_, error) in
            self?.activityIndicator.stopAnimating()
            self?.activityIndicator.isHidden = true
            self?.completion?()
        }        
    }
}

protocol UIStoryViewProtocol {
    var completion: (() -> Void)? { get set }
    func startLoad()
}
