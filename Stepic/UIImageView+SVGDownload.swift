//
//  UIImageView+SVGDownload.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.02.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import SDWebImage
import Alamofire
#if os(iOS)
import SVGKit
#endif

extension UIImageView {
    
    func setImageWithURL(url optionalURL: URL?, placeholder: UIImage, completion: @escaping () -> Void) {
        
        guard let url = optionalURL else {
            self.image = placeholder
            return
        }
        
        if url.pathExtension != "svg" {
            self.sd_setImage(with: optionalURL, placeholderImage: placeholder, options: SDWebImageOptions.retryFailed, completed: { (image, error, cacheType, url) in
                
                completion()
            })
        } else {
            self.image = placeholder
            #if os(iOS)
                Alamofire.request(url).responseData(completionHandler: {
                    response in
                    if response.result.error != nil {
                        return
                    }
                    
                    guard let data = response.result.value else {
                        return
                    }
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        let svgImage = SVGKImage(data: data)
                        if !(svgImage?.hasSize() ?? true) {
                            svgImage?.size = CGSize(width: 200, height: 200)
                        }
                        let img = svgImage?.uiImage ?? placeholder
                        DispatchQueue.main.async {
                            self.image = img
                        }
                    }
                    
                })
            #endif
        }
        
    }
        
    func setImageWithURL(url optionalURL: URL?, placeholder: UIImage) {
        
        self.setImageWithURL(url: optionalURL, placeholder: placeholder, completion: { });
        
    }
}
