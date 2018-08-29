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
        let source = LearningTopicsCollectionSource()
        let controller = TopicsViewController(dataSource: source, delegate: source)
        let presenter = makePresenter(view: controller, navigationController: navigationController)
        controller.presenter = presenter
        source.didSelectTopic = {
            var topic = $0
            topic.type = .theory
            presenter.selectTopic(topic)
        }

        return controller
    }

    func training(navigationController: UINavigationController) -> UIViewController {
        let source = TrainingTopicsCollectionSource()
        let controller = TopicsViewController(dataSource: source, delegate: source)
        controller.presenter = makePresenter(
            view: controller,
            navigationController: navigationController
        )
        source.didSelectTopic = controller.presenter.selectTopic

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
