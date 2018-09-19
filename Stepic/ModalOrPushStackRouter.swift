//
//  ModalOrPushStackRouter.swift
//  Stepic
//
//  Created by Ostrenkiy on 14.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import SafariServices

class ModalOrPushStackRouter: SourcelessRouter, RouterProtocol {

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
        guard let router = router else {
            if let source = source, let fallbackPath = fallbackPath {
                openWeb(path: fallbackPath, from: source)
            }
            return
        }
        router.route()
    }

    private func openWeb(path: String, from source: UIViewController) {
        guard let url = URL(string: path) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        source.present(vc, animated: true, completion: nil)
    }
}
