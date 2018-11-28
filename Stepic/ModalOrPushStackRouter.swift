//
//  ModalOrPushStackRouter.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import SafariServices

final class ModalOrPushStackRouter: SourcelessRouter, RouterProtocol {
    var router: RouterProtocol?
    var fallbackPath: String?
    var source: UIViewController?

    init(
        source optionalSource: UIViewController?,
        destinationStack: [UIViewController],
        embedInNavigation: Bool,
        fallbackPath: String
    ) {
        super.init()
        let possibleSource = currentNavigation?.topViewController
        guard let source = optionalSource ?? possibleSource else {
            return
        }
        self.source = source
        self.fallbackPath = fallbackPath
        if destinationStack.count == 1 && source.navigationController == nil {
            router = ModalRouter(source: source, destination: destinationStack[0], embedInNavigation: embedInNavigation)
        }
        if destinationStack.count == 1 && source.navigationController != nil {
            router = PushRouter(source: source, destination: destinationStack[0])
        }
        if destinationStack.count > 1 && source.navigationController == nil {
            router = ModalStackRouter(source: source, destinationStack: destinationStack)
        }
        if destinationStack.count > 1 && source.navigationController != nil {
            router = PushStackRouter(source: source, destinationStack: destinationStack)
        }
    }

    func route() {
        if let router = self.router {
            router.route()
        } else if let source = self.source,
                  let fallbackPath = self.fallbackPath,
                  !fallbackPath.isEmpty {
            self.openWeb(path: fallbackPath, from: source)
        }
    }

    private func openWeb(path: String, from source: UIViewController) {
        if let url = URL(string: path)?.appendingQueryParameters(["from_mobile_app": "true"]) {
            source.present(SFSafariViewController(url: url), animated: true)
        }
    }
}
