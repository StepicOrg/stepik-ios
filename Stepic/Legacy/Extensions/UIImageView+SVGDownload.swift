//
//  UIImageView+SVGDownload.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.02.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Alamofire
import Foundation
import SDWebImage
import SVGKit

extension UIImageView {
    func setImageWithURL(
        url urlOrNil: URL?,
        placeholder: UIImage,
        completion: (() -> Void)? = nil
    ) {
        guard let url = urlOrNil else {
            self.image = placeholder
            completion?()
            return
        }

        if url.pathExtension == "svg" {
            self.image = placeholder

            AlamofireDefaultSessionManager
                .shared
                .request(url)
                .responseData { dataResponse in
                    guard let data = dataResponse.data else {
                        completion?()
                        return
                    }

                    DispatchQueue.global(qos: .userInitiated).async {
                        let svgImage = SVGKImage(data: data)

                        if !(svgImage?.hasSize() ?? true) {
                            svgImage?.size = CGSize(width: 200, height: 200)
                        }

                        let image = svgImage?.uiImage ?? placeholder

                        DispatchQueue.main.async {
                            self.image = image
                            completion?()
                        }
                    }
                }
        } else {
            self.sd_setImage(with: urlOrNil, placeholderImage: placeholder, options: .retryFailed) { (_, _, _, _) in
                completion?()
            }
        }
    }
}
