//
//  CyrillicURLActivityItemSource.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import TUSafariActivity

class CyrillicURLActivityItemSource: NSObject, UIActivityItemSource {

    var link: String
    var url: URL? {
        return URL(string: link.addingPercentEscapes(using: String.Encoding.utf8)!)
    }

    init(link: String) {
        self.link = link
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        if let url = self.url {
            return url
        } else {
            return link
        }
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        print("\(activityType)")
        switch activityType.rawValue {
        case "TUSafariActivity" :
            if let url = self.url {
                return url
            } else {
                return link
            }
        default:
            return link
        }
    }
}
