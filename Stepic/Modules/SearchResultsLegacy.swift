//
//  SearchResultsLegacy.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 28.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

protocol SearchResultsModuleInputProtocol: class {
    func queryChanged(to query: String)
    func search(query: String)
    func searchStarted()
    func searchCancelled()
}

@available(*, deprecated, message: "Class for backward compatibility")
final class SearchResultsAssembly: Assembly {
    var moduleInput: SearchResultsModuleInputProtocol?
    private let updateQueryBlock: ((String) -> Void)?

    init(updateQueryBlock: ((String) -> Void)?) {
        self.updateQueryBlock = updateQueryBlock
    }

    func makeModule() -> UIViewController {
        guard let controller = ControllerHelper.instantiateViewController(
            identifier: "SearchResultsViewController",
            storyboardName: "Explore"
        ) as? SearchResultsViewController else {
            fatalError("Failed to init module from storyboard")
        }
        controller.presenter = SearchResultsPresenter(view: controller)
        controller.presenter?.updateQueryBlock = updateQueryBlock
        self.moduleInput = controller.presenter
        return controller
    }
}
