//
//  TopicsPresenterImpl.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

final class TopicsPresenterImpl: TopicsPresenter {
    private weak var view: TopicsView?
    private let router: TopicsRouter

    private let knowledgeGraph: KnowledgeGraph
    private var segmentSelectedIndex = 0

    private let userRegistrationService: UserRegistrationService
    private let graphService: GraphService

    init(view: TopicsView, knowledgeGraph: KnowledgeGraph, router: TopicsRouter,
         userRegistrationService: UserRegistrationService, graphService: GraphService) {
        self.view = view
        self.knowledgeGraph = knowledgeGraph
        self.router = router
        self.userRegistrationService = userRegistrationService
        self.graphService = graphService
    }

    func refresh() {
        view?.setSegments([SegmentItem.all.title, SegmentItem.adaptive.title])
        view?.selectSegment(at: segmentSelectedIndex)

        checkAuthStatus()
        fetchGraphData()
    }

    func selectTopic(with viewData: TopicsViewData) {
        guard let topic = knowledgeGraph[viewData.id]?.key,
              let segment = SegmentItem(rawValue: segmentSelectedIndex) else {
            return
        }

        if segment == .all {
            router.showLessonsForTopicWithId(topic.id)
        } else {
            router.showAdaptive()
        }
    }

    func selectSegment(at index: Int) {
        segmentSelectedIndex = index
    }

    func signIn() {
        router.showAuth()
    }

    func logout() {
        AuthInfo.shared.token = nil
    }

    // MARK: - Private API

    private func checkAuthStatus() {
        if !AuthInfo.shared.isAuthorized {
            let params = RandomCredentialsGenerator().userRegistrationParams
            userRegistrationService.registerAndSignIn(with: params).then { [unowned self] user in
                self.userRegistrationService.unregisterFromEmail(user: user)
            }.done { user in
                print("Successfully register fake user with id: \(user.id)")
            }.catch { [weak self] error in
                self?.displayError(error)
            }
        }
    }

    private func fetchGraphData() {
        graphService.fetchGraph().done { [weak self] responseModel in
            guard let `self` = self else {
                return
            }

            let builder = KnowledgeGraphBuilder(graphPlainObject: responseModel)
            guard let graph = builder.build() as? KnowledgeGraph,
                  let vertices = graph.vertices as? [KnowledgeGraphVertex<String>] else {
                return
            }

            self.knowledgeGraph.adjacency = graph.adjacency
            self.view?.setTopics(self.viewTopicsFrom(vertices))

            print(self.knowledgeGraph)

            let url = TopicsPresenterImpl
                .getURL(for: .caches)
                .appendingPathComponent("knowledgeGraph", isDirectory: false)

            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(self.knowledgeGraph)
                let fileManager = FileManager.default
                if fileManager.fileExists(atPath: url.path) {
                    try fileManager.removeItem(at: url)
                }
                fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
            }

            if let data = FileManager.default.contents(atPath: url.path) {
                let decoder = JSONDecoder()
                do {
                    let decodedGraph = try decoder.decode(KnowledgeGraph.self, from: data)
                    print("************************\n\(decodedGraph)")
                } catch {
                    fatalError(error.localizedDescription)
                }
            } else {
                fatalError("No data at \(url.path)!")
            }
        }.catch { [weak self] error in
            self?.displayError(error)
        }
    }

    enum Directory {
        // Only documents and other data that is user-generated, or that cannot otherwise be recreated by your application, should be stored in the <Application_Home>/Documents directory and will be automatically backed up by iCloud.
        case documents

        // Data that can be downloaded again or regenerated should be stored in the <Application_Home>/Library/Caches directory. Examples of files you should put in the Caches directory include database cache files and downloadable content, such as that used by magazine, newspaper, and map applications.
        case caches
    }

    /// Returns URL constructed from specified directory
    static fileprivate func getURL(for directory: Directory) -> URL {
        var searchPathDirectory: FileManager.SearchPathDirectory

        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .caches:
            searchPathDirectory = .cachesDirectory
        }

        if let url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Could not create URL for specified directory!")
        }
    }

    private func displayError(_ error: Swift.Error) {
        view?.displayError(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription)
    }

    private func viewTopicsFrom(_ vertices: [KnowledgeGraphVertex<String>]) -> [TopicsViewData] {
        return vertices.map { viewTopicFromVertex($0) }
    }

    private func viewTopicFromVertex(_ vertex: KnowledgeGraphVertex<String>) -> TopicsViewData {
        return TopicsViewData(id: vertex.id, title: vertex.title)
    }

    // MARK: - Types

    private enum SegmentItem: Int {
        case all
        case adaptive

        var title: String {
            switch self {
            case .all:
                return NSLocalizedString("All", comment: "")
            case .adaptive:
                return NSLocalizedString("Adaptive", comment: "")
            }
        }

        static func segment(at index: Int) -> SegmentItem? {
            return SegmentItem(rawValue: index)
        }
    }
}
