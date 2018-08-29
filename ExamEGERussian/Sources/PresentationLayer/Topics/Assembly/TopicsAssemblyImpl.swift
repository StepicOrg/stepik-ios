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
        let controller = makeController(source: source, navigationController: navigationController)
        source.didSelectTopic = {
            var topic = $0
            topic.type = .theory
            controller.presenter.selectTopic(topic)
        }

        return controller
    }

    func training(navigationController: UINavigationController) -> UIViewController {
        let source = TrainingTopicsCollectionSource()
        let controller = makeController(source: source, navigationController: navigationController)
        source.didSelectTopic = controller.presenter.selectTopic

        return controller
    }

    private func makeController(
        source: TopicsCollectionViewSourceProtocol,
        navigationController: UINavigationController
    ) -> TopicsViewController {
        let controller = TopicsViewController(source: source)
        let router = TopicsRouterImpl(
            assemblyFactory: assemblyFactory,
            navigationController: navigationController
        )
        let presenter = TopicsPresenterImpl(
            view: controller,
            knowledgeGraph: serviceFactory.knowledgeGraphProvider.knowledgeGraph,
            router: router,
            userRegistrationService: serviceFactory.userRegistrationService,
            graphService: serviceFactory.graphService
        )
        controller.presenter = presenter

        return controller
    }
}
