//
//  CyrillicURLActivityItemSource.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import TUSafariActivity

class CyrillicURLActivityItemSource : NSObject, UIActivityItemSource {
    
    var link: String
    var url : NSURL? {
        return NSURL(string: link.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    init(link: String) {
        self.link = link
    }
    
    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
        if let url = self.url {
            return url
        } else {
            return link
        }
    }
    
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        print("\(activityType)")
        switch activityType {
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

