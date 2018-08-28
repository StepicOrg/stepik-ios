//
//  TopicsAssemblyImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 25/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class TopicsAssemblyImpl: BaseAssembly, TopicsAssembly {
    func learning(navigationController: UINavigationController) -> UIViewController {
        let controller = TopicsTableViewController()
        controller.presenter = makePresenter(
            view: controller,
            navigationController: navigationController
        )

        return controller
    }

    func training(navigationController: UINavigationController) -> UIViewController {
        let dataSource = TrainingTopicsViewDataSource()
        let delegate = TrainingTopicsViewDelegate()
        let controller = TopicsViewController(
            dataSource: dataSource,
            delegate: delegate
        )
        dataSource.delegate = controller
        controller.presenter = makePresenter(
            view: controller,
            navigationController: navigationController
        )

        return controller
    }

    private func makePresenter(
        view: TopicsView,
        navigationController: UINavigationController
    ) -> TopicsPresenter {
        let router = TopicsRouterImpl(
            assemblyFactory: assemblyFactory,
            navigationController: navigationController
        )

        return TopicsPresenterImpl(
            view: view,
            knowledgeGraph: serviceFactory.knowledgeGraphProvider.knowledgeGraph,
            router: router,
            userRegistrationService: serviceFactory.userRegistrationService,
            graphService: serviceFactory.graphService
        )
    }
}
