//
//  UIImageView+SVGDownload.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.02.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import SDWebImage
import SVGKit

extension UIImageView {
    func setImageWithURL(url optionalURL: URL?, placeholder: UIImage) {
        
        guard let url = optionalURL else {
            self.image = placeholder
            return 
        }
        
        if url.pathExtension != "svg" {
            self.sd_setImage(with: url, placeholderImage: placeholder)
        } else {
            self.image = placeholder
            let svgImage = SVGKImage(contentsOf: url)
            
            if !(svgImage?.hasSize() ?? true)  {
                svgImage?.size = CGSize(width: 200, height: 200)
            }
            self.image = svgImage?.uiImage ?? placeholder
        }
    }
}
