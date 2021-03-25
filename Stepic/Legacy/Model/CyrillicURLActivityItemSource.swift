//
//  CyrillicURLActivityItemSource.swift
//  Stepic
//
//  Created by Alexander Karpov on 17.08.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import TUSafariActivity
import UIKit

final class CyrillicURLActivityItemSource: NSObject, UIActivityItemSource {
    let link: String

    var url: URL? {
        if let percentEncodedString = self.link.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URL(string: percentEncodedString)
        }
        return nil
    }

    init(link: String) {
        self.link = link
    }

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        if let url = self.url {
            return url
        } else {
            return self.link
        }
    }

    func activityViewController(
        _ activityViewController: UIActivityViewController,
        itemForActivityType activityType: UIActivity.ActivityType?
    ) -> Any? {
        print("Activity type is \(activityType ??? "unknown")")
        switch activityType?.rawValue {
        case "TUSafariActivity":
            if let url = self.url {
                return url
            } else {
                return self.link
            }
        default:
            return self.link
        }
    }
}
