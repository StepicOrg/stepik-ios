//
//  SyllabusDownloadsInteractionService.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27/12/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

/// Representation of subtree in syllabus tree
final class SyllabusTreeNode {
    enum Source: Equatable, Hashable {
        case course(id: Course.IdType)
        case section(id: Section.IdType)
        case unit(id: Unit.IdType)
        case step(id: Step.IdType)
        case video(entity: Video)

        static func > (lhs: SyllabusTreeNode.Source, rhs: SyllabusTreeNode.Source) -> Bool {
            return lhs.observationLevel > rhs.observationLevel
        }

        var observationLevel: Int {
            switch self {
            case .course(_):
                return 0
            case .section(_):
                return 1
            case .unit(_):
                return 2
            case .step(_):
                return 3
            case .video(_):
                return 4
            }
        }

        static func == (lhs: Source, rhs: Source) -> Bool {
            switch (lhs, rhs) {
            case (.video(let a), .video(let b)):
                return a.id == b.id
            case (.step(let a), .step(let b)):
                return a == b
            case (.unit(let a), .unit(let b)):
                return a == b
            case (.section(let a), .section(let b)):
                return a == b
            case (.course(_), .course(_)):
                return true
            default:
                return false
            }
        }

        var description: String {
            switch self {
            case .video(let entity):
                return ".video(id = \(entity.id))"
            case .step(let id):
                return ".step(id = \(id))"
            case .unit(let id):
                return ".unit(id = \(id))"
            case .section(let id):
                return ".section(id = \(id))"
            case .course(_):
                return ".course"
            }
        }
    }

    let value: Source
    let children: [SyllabusTreeNode]

    init(value: Source, children: [SyllabusTreeNode] = []) {
        self.value = value
        self.children = children
    }

    var isLeaf: Bool {
        return self.children.isEmpty
    }

    /// Recursive validate node (correct order, correct root, etc)
    var isValid: Bool {
        // Check whether leaf-node represents Video
        if self.isLeaf {
            if case .video(_) = self.value {
                return true
            }
            return false
        }

        // All children should have correct order (course < section < unit < step)
        let childrenHaveCorrectLevel = !self.children.map { $0.value > self.value }.contains(false)
        let childrenAreValid = !self.children.map { $0.isValid }.contains(false)
        return childrenHaveCorrectLevel && childrenAreValid
    }
}

protocol SyllabusDownloadsInteractionServiceDelegate: class {
    func downloadsInteractionService(
        _ downloadsInteractionService: SyllabusDownloadsInteractionServiceProtocol,
        didReceiveProgress progress: Float,
        source: SyllabusTreeNode.Source
    )
    func downloadsInteractionService(
        _ downloadsInteractionService: SyllabusDownloadsInteractionServiceProtocol,
        didReceiveCompletion completed: Bool,
        source: SyllabusTreeNode.Source
    )
}

protocol SyllabusDownloadsInteractionServiceProtocol: class {
    var delegate: SyllabusDownloadsInteractionServiceDelegate? { get set }

    /// Download part of syllabus
    func startDownloading(syllabusTree: SyllabusTreeNode) throws
    /// Stop downloading for part of syllabus
    func cancelDownloading(syllabusTree: SyllabusTreeNode) throws
    /// Try to restore active downloads for part of syllabus
    func restoreDownloading(syllabusTree: SyllabusTreeNode) throws
    /// Progress for video
    func getDownloadProgress(for video: Video) -> Float?
}

/// Service stores tree-like structure of syllabus and manages all downloading operation
final class SyllabusDownloadsInteractionService: SyllabusDownloadsInteractionServiceProtocol {
    weak var delegate: SyllabusDownloadsInteractionServiceDelegate? {
        didSet {
            // Subscribe on events
            if self.shouldSubscribeOnEvents {
                self.videoDownloadingService.subscribeOnEvents { event in
                    self.handleUpdate(event: event)
                }
                self.shouldSubscribeOnEvents = false
            }
        }
    }

    private let videoDownloadingService: VideoDownloadingServiceProtocol

    private var trees: [DownloadsTreeNode] = []
    private var activeVideoDownloads: [Video.IdType: DownloadsTreeNode] = [:]
    private var shouldSubscribeOnEvents = true

    init(videoDownloadingService: VideoDownloadingServiceProtocol) {
        self.videoDownloadingService = videoDownloadingService
    }

    // MARK: Public methods

    func startDownloading(syllabusTree: SyllabusTreeNode) throws {
        guard syllabusTree.isValid else {
            throw Error.invalidNode
        }

        let targetTree = DownloadsTreeNode.makeDownloadsTreeNodeRecursive(syllabusSubtree: syllabusTree)
        self.merge(with: targetTree)

        let allNodes = self.trees.map { $0.flatten() }.reduce([], +)

        for node in allNodes {
            if node.delegate == nil {
                node.delegate = self
            }

            guard case .video(let video) = node.source else {
                continue
            }

            if !self.activeVideoDownloads.keys.contains(video.id) {
                try? self.videoDownloadingService.download(video: video)
                self.activeVideoDownloads[video.id] = node
            }
        }
    }

    func cancelDownloading(syllabusTree: SyllabusTreeNode) throws {
        guard syllabusTree.isValid else {
            throw Error.invalidNode
        }

        let targetTree = DownloadsTreeNode.makeDownloadsTreeNodeRecursive(syllabusSubtree: syllabusTree)

        for case .video(let video) in targetTree.flatten().map({ $0.source }) {
            if self.activeVideoDownloads.keys.contains(video.id) {
                try? self.videoDownloadingService.cancelDownload(videoID: video.id)
            }
        }
    }

    // Before downloading try to restore active download
    // If videoDownloadingService reports that download exists then add node to tree
    // otherwise skip
    func restoreDownloading(syllabusTree: SyllabusTreeNode) throws {
        guard syllabusTree.isValid else {
            throw Error.invalidNode
        }

        let targetTree = DownloadsTreeNode.makeDownloadsTreeNodeRecursive(syllabusSubtree: syllabusTree)
        self.merge(with: targetTree)

        let allNodes = self.trees.map { $0.flatten() }.reduce([], +)

        for node in allNodes {
            guard case .video(let video) = node.source else {
                continue
            }

            if !self.activeVideoDownloads.keys.contains(video.id) {
                if self.videoDownloadingService.isTaskActive(videoID: video.id) {
                    node.delegate = self
                    self.activeVideoDownloads[video.id] = node
                } else {
                    node.detachFromParent()
                }
            }
        }
        self.cleanDeadNodes()
    }

    func getDownloadProgress(for video: Video) -> Float? {
        if let node = self.activeVideoDownloads[video.id],
           case .downloading(let progress) = node.state {
            return progress
        }
        return nil
    }

    // MARK: Private methods

    private func merge(with tree: DownloadsTreeNode) {
        // Trying to replace node from `tree` by `targetTree`
        for index in 0..<self.trees.count {
            let mergedTrees = DownloadsTreeNode.tryToMerge(firstTree: self.trees[index], secondTree: tree)
            if mergedTrees.count > 1 {
                continue
            }

            self.trees[index] = mergedTrees[0]
            return
        }

        self.trees.append(tree)
    }

    private func cleanDeadNodes() {
        // Try to shrink
        self.trees = self.trees.filter { $0.shrink() }
    }

    /// Handle events from downloading service
    private func handleUpdate(event: VideoDownloadingServiceEvent) {
        guard let node = self.activeVideoDownloads[event.videoID] else {
            return
        }

        switch event.state {
        case .error:
            // Downloading failed, remove task and detach from parent
            node.updateState(with: .finished(completed: false))
            node.invalidateNodesUpTheTree()
            node.detachFromParent()
            self.activeVideoDownloads.removeValue(forKey: event.videoID)
            self.cleanDeadNodes()
        case .active(let progress):
            node.updateState(with: .downloading(progress: progress))
            node.invalidateNodesUpTheTree()
        case .completed(_):
            node.updateState(with: .finished(completed: true))
            node.invalidateNodesUpTheTree()
            self.activeVideoDownloads.removeValue(forKey: event.videoID)
            self.cleanDeadNodes()
        }
    }

    enum Error: Swift.Error {
        case invalidNode
    }
}

extension SyllabusDownloadsInteractionService: DownloadsTreeNodeDelegate {
    func downloadsTreeNodeDidUpdateState(_ downloadsTreeNode: DownloadsTreeNode) {
        print("syllabus downloads interaction service: reports new state for node: "
            + "source = \(downloadsTreeNode.source.description), state = \(downloadsTreeNode.state)")
        switch downloadsTreeNode.state {
        case .downloading(let progress):
            self.delegate?.downloadsInteractionService(
                self,
                didReceiveProgress: progress,
                source: downloadsTreeNode.source
            )
        case .finished(let completed):
            self.delegate?.downloadsInteractionService(
                self,
                didReceiveCompletion: completed,
                source: downloadsTreeNode.source
            )
        }
    }
}

// MARK: - DownloadsTreeNode classes

protocol DownloadsTreeNodeDelegate: class {
    func downloadsTreeNodeDidUpdateState(_ downloadsTreeNode: DownloadsTreeNode)
}

/// Representation of SyllabusTreeNode in SyllabusDownloadsInteractionService
final class DownloadsTreeNode {
    private(set) var source: SyllabusTreeNode.Source

    private(set) var parent: DownloadsTreeNode?
    private(set) var children: [DownloadsTreeNode] = []

    private var currentState: State?

    weak var delegate: DownloadsTreeNodeDelegate?

    var state: State {
        return self.currentState ?? self.updateAndReturnState()
    }

    var isLeaf: Bool {
        if case .video(_) = self.source {
            if !self.children.isEmpty {
                assertionFailure("Only node with source == .video can be leaf")
            }
            return true
        }

        return false
    }

    private init(
        source: SyllabusTreeNode.Source,
        parentNode: DownloadsTreeNode?,
        children: [DownloadsTreeNode]
    ) {
        self.source = source
        self.parent = parentNode
        self.children = children
    }

    static func makeDownloadsTreeNodeRecursive(syllabusSubtree: SyllabusTreeNode) -> DownloadsTreeNode {
        func makeDownloadsTreeNodeRecursive(
            syllabusSubtree: SyllabusTreeNode,
            parentNode: DownloadsTreeNode? = nil
        ) -> DownloadsTreeNode {
            let rootNode = DownloadsTreeNode(
                source: syllabusSubtree.value,
                parentNode: parentNode,
                children: []
            )
            let childrenNodes: [DownloadsTreeNode] = syllabusSubtree.children.map { node in
                makeDownloadsTreeNodeRecursive(syllabusSubtree: node, parentNode: rootNode)
            }
            rootNode.children = childrenNodes
            return rootNode
        }

        return makeDownloadsTreeNodeRecursive(syllabusSubtree: syllabusSubtree)
    }

    /// Detach from parent
    func detachFromParent() {
        self.parent?.children.removeAll(where: { $0 === self })
        self.parent = nil
    }

    /// Update node state; available only for nodes with source == .video
    func updateState(with newState: State) {
        guard self.isLeaf else {
            return
        }

        self.currentState = newState
    }

    /// After invalidating, nodes up the tree should recalculate own state
    func invalidateNodesUpTheTree() {
        func invalidate(node: DownloadsTreeNode?) {
            if let currentNode = node {
                currentNode.currentState = nil
                invalidate(node: currentNode.parent)
                currentNode.updateAndReturnState()
            }
        }
        invalidate(node: self.parent)
    }

    /// Return list of nodes in NLR traverse order (from root to leafs)
    // see: https://en.wikipedia.org/wiki/Tree_traversal#Pre-order_(NLR)
    func flatten() -> [DownloadsTreeNode] {
        return [self] + self.children.map { node -> [DownloadsTreeNode] in node.flatten() }.reduce([], +)
    }

    /// Remove dead child nodes and return true if node is dead after shrink operation
    func shrink() -> Bool {
        if self.children.isEmpty {
            if case .finished(_) = self.state {
                return true
            }
            return false
        }

        self.children = self.children.filter { !$0.shrink() }
        return self.children.isEmpty
    }

    /// Try to merge given tree with source tree and return result (common tree or both trees)
    static func tryToMerge(firstTree: DownloadsTreeNode, secondTree: DownloadsTreeNode) -> [DownloadsTreeNode] {
        // To update root
        var firstTree = firstTree

        // Add fake node `nil` node
        // TopologyEdge – edge in tree that contains sources
        typealias TopologyEdge = (from: SyllabusTreeNode.Source?, to: SyllabusTreeNode.Source)
        func getAllEdges(in tree: DownloadsTreeNode, parent: DownloadsTreeNode? = nil) -> [TopologyEdge] {
            return [(from: parent?.source, to: tree.source)]
                + tree.children.map { getAllEdges(in: $0, parent: tree) }.reduce([], +)
        }

        let sourceEdges: [TopologyEdge] = getAllEdges(in: firstTree)
        let targetEdges: [TopologyEdge] = getAllEdges(in: secondTree)

        // Get edges
        let targetFilteredEdges = targetEdges.filter { edge in
            !sourceEdges.contains(where: { sourceEdge in
                edge.from == sourceEdge.from && edge.to == sourceEdge.to
            })
        }

        // Get topsort on distinct edges subset
        func getTopologicalSortOrder(edges: [TopologyEdge]) -> [SyllabusTreeNode.Source] {
            var graph: [SyllabusTreeNode.Source: SyllabusTreeNode.Source] = [:]
            var visited: [SyllabusTreeNode.Source: Bool] = [:]

            for edge in edges {
                if let from = edge.from {
                    let to = edge.to
                    graph[to] = from
                    visited[to] = false
                    visited[from] = false
                }
            }

            func dfs(sourceNode: SyllabusTreeNode.Source) -> [SyllabusTreeNode.Source] {
                if visited[sourceNode] ?? true {
                    return []
                }

                visited[sourceNode] = true
                // There is only one node cause we have reversed tree
                if let adjacentNode = graph[sourceNode] {
                    return dfs(sourceNode: adjacentNode) + [sourceNode]
                }
                return [sourceNode]
            }

            return visited.keys.map { dfs(sourceNode: $0) }.reduce([], +)
        }

        let topologicalSortOrder = getTopologicalSortOrder(edges: targetEdges)
        for node in topologicalSortOrder {
            for edgeToNode in targetFilteredEdges where edgeToNode.to == node {
                let currentTreeNodes = firstTree.flatten()
                if let existingNode = currentTreeNodes.first(where: { $0.source == node }) {
                    // Find node & set new parent for it
                    guard let fromNodeSource = edgeToNode.from else {
                        if node.observationLevel > firstTree.source.observationLevel {
                            continue
                        } else {
                            fatalError("Invalid state: same node in different trees has different observationLevel")
                        }
                    }

                    guard let parentNode = currentTreeNodes.first(where: { $0.source == fromNodeSource }) else {
                        fatalError("Invalid state: current tree should contain parent node due to topsort order")
                    }

                    existingNode.parent = parentNode
                    if !parentNode.children.contains(where: { $0.source == existingNode.source }) {
                        parentNode.children.append(existingNode)
                    }
                } else {
                    // Insert new node
                    guard let newDownloadNodeInSecondTree = secondTree.flatten().first(where: { $0.source == node }) else {
                        fatalError("Invalid state: target tree should contain node from source-tree")
                    }

                    let newDownloadNode = DownloadsTreeNode(
                        source: newDownloadNodeInSecondTree.source,
                        parentNode: nil,
                        children: []
                    )

                    if let fromNodeSource = edgeToNode.from {
                        // Find parent
                        guard let parentNode = currentTreeNodes.first(where: { $0.source == fromNodeSource }) else {
                            fatalError("Invalid state: current tree should contain parent node due to topsort order")
                        }

                        parentNode.children.append(newDownloadNode)
                        newDownloadNode.parent = parentNode
                        newDownloadNode.children = []
                    } else {
                        // New root?
                        if firstTree.source.observationLevel > newDownloadNode.source.observationLevel {
                            // New root
                            newDownloadNode.children = [firstTree]
                            newDownloadNode.parent = nil
                            firstTree = newDownloadNode
                        } else {
                            // Another tree
                            // Can return here: if root node belongs to another tree then all nodes belong to another tree
                            return [firstTree, secondTree]
                        }
                    }
                }
            }
        }
        return [firstTree]
    }

    @discardableResult
    private func updateAndReturnState() -> State {
        // For leafs: if state is nil then node in waiting for download state
        // Is this call possible?
        if self.isLeaf {
            return self.currentState ?? .downloading(progress: 0)
        }

        // If any children failed -> current node failed
        // If all childrens succeed -> current node succeed
        // Otherwise current node downloading
        let childrensDownloadingPercentage = self.children.map { child -> Float in
            switch child.state {
            case .downloading(let progress):
                return progress
            case .finished(let completed):
                return completed ? 1.0 : 0.0
            }
        }.reduce(0, +) / Float(self.children.count)

        let failedChildrensCount = self.children.map { child -> Int in
            switch child.state {
            case .downloading(_):
                return 0
            case .finished(let completed):
                return completed ? 0 : 1
            }
        }.reduce(0, +)

        let downloadingChildrensCount = self.children.map { child -> Int in
            switch child.state {
            case .downloading(_):
                return 1
            default:
                return 0
            }
        }.reduce(0, +)

        let succeedChildrensCount = self.children.map { child -> Int in
            switch child.state {
            case .downloading(_):
                return 0
            case .finished(let completed):
                return completed ? 1 : 0
            }
        }.reduce(0, +)

        let state: State
        if failedChildrensCount > 0 && downloadingChildrensCount == 0 {
            state = .finished(completed: false)
        } else if succeedChildrensCount == self.children.count && downloadingChildrensCount == 0 {
            state = .finished(completed: true)
        } else {
            state = .downloading(progress: childrensDownloadingPercentage)
        }

        self.currentState = state
        self.delegate?.downloadsTreeNodeDidUpdateState(self)
        return state
    }

    enum State {
        case finished(completed: Bool)
        case downloading(progress: Float)
    }
}
