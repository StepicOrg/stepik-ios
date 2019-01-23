//
//  SyllabusDownloadsInteractionService.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27/12/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

/// Representation of one syllabus path (course -> section -> unit (lesson) -> steps)
struct SyllabusCut {
    enum ObservationLevel: Int, Comparable {
        case unit = 0
        case section = 1
        case all = 2

        static func < (lhs: SyllabusCut.ObservationLevel, rhs: SyllabusCut.ObservationLevel) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }

    @available(*, deprecated, message: "Plain object should be used")
    let steps: [Step]
    @available(*, deprecated, message: "Plain object should be used")
    let unit: Unit
    @available(*, deprecated, message: "Plain object should be used")
    let section: Section
    let observationLevel: ObservationLevel
}

/// Source that reports about download
enum DownloadSource: Equatable, CustomStringConvertible {
    case step(entity: Step)
    case unit(entity: Unit)
    case section(entity: Section)
    case course

    static func == (lhs: DownloadSource, rhs: DownloadSource) -> Bool {
        switch (lhs, rhs) {
        case (.step(let a), .step(let b)):
            return a.id == b.id
        case (.unit(let a), .unit(let b)):
            return a.id == b.id
        case (.section(let a), .section(let b)):
            return a.id == b.id
        case (.course, .course):
            return true
        default:
            return false
        }
    }

    var description: String {
        switch self {
        case .step(let step):
            return ".step(id = \(step.id))"
        case .unit(let unit):
            return ".unit(id = \(unit.id))"
        case .section(let section):
            return ".section(id = \(section.id))"
        case .course:
            return ".course"
        }
    }
}

protocol SyllabusDownloadsInteractionServiceDelegate: class {
    func downloadsInteractionService(
        _ downloadsInteractionService: SyllabusDownloadsInteractionServiceProtocol,
        didReceiveProgress progress: Float,
        source: DownloadSource
    )
    func downloadsInteractionService(
        _ downloadsInteractionService: SyllabusDownloadsInteractionServiceProtocol,
        didReceiveCompletion completed: Bool,
        source: DownloadSource
    )
}

protocol SyllabusDownloadsInteractionServiceProtocol: class {
    var delegate: SyllabusDownloadsInteractionServiceDelegate? { get set }

    /// Download unit/section/course
    func startDownloading(cut: SyllabusCut)
    /// Stop downloading for unit/section/course
    func stopDownloading(cut: SyllabusCut)
}

/// Service stores tree-like structure of syllabus and manages all downloading operation
final class SyllabusDownloadsInteractionService: SyllabusDownloadsInteractionServiceProtocol {
    private let videoDownloadingService: VideoDownloadingServiceProtocol

    private var shouldSubscribeOnEvents = true

    /// Current downloads observed by service
    private var currentDownloads: [DownloaderTaskProtocol.IDType: DownloadTreeNode] = [:]
    /// List of created nodes
    private var currentTreeNodes: [DownloadTreeNode] = []

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

    init(videoDownloadingService: VideoDownloadingServiceProtocol) {
        self.videoDownloadingService = videoDownloadingService
    }

    /// Download unit/section/course; target entity can be determined by observation level
    func startDownloading(cut: SyllabusCut) {
        let observer: DownloadTreeNode.Observer = { [weak self] node in
            guard let strongSelf = self else {
                return
            }

            switch node.state {
            case .downloading(let progress):
                strongSelf.delegate?.downloadsInteractionService(
                    strongSelf,
                    didReceiveProgress: progress,
                    source: node.source
                )
            case .finished(let completed):
                strongSelf.delegate?.downloadsInteractionService(
                    strongSelf,
                    didReceiveCompletion: completed,
                    source: node.source
                )
            }
        }

        // TODO: handle case when lesson doesn't have steps with video
        let stepsWithVideo = cut.steps.filter { $0.block.name == "video" }

        var stepsTreeNodes: [DownloadTreeNode] = []
        var videosForDownloading: [(DownloadTreeNode, Video)] = []
        for step in stepsWithVideo {
            guard let video = step.block.video else {
                continue
            }

            let node = DownloadTreeNode(
                source: .step(entity: step),
                childrens: [],
                observer: observer
            )

            stepsTreeNodes.append(node)
            videosForDownloading.append((node, video))
        }

        // Build tree: create new or merge
        // Unit
        let unitSource = DownloadSource.unit(entity: cut.unit)
        let existingUnitTreeNodeIndex = self.currentTreeNodes.firstIndex(where: { $0.source == unitSource })
        let newUnitTreeNode = self.createTreeNodeInTree(
            existingTreeNodeIndex: existingUnitTreeNodeIndex,
            source: unitSource,
            childrens: &stepsTreeNodes,
            shouldReportProgress: cut.observationLevel >= .unit,
            observer: observer
        )

        // Section
        let sectionSource = DownloadSource.section(entity: cut.section)
        let existingSectionTreeNodeIndex = self.currentTreeNodes.firstIndex(where: { $0.source == sectionSource })
        var sectionChildrens = [newUnitTreeNode].compactMap { $0 }
        let newSectionTreeNode = self.createTreeNodeInTree(
            existingTreeNodeIndex: existingSectionTreeNodeIndex,
            source: sectionSource,
            childrens: &sectionChildrens,
            shouldReportProgress: cut.observationLevel >= .section,
            observer: observer
        )

        // Course
        let courseSource = DownloadSource.course
        let existingCourseTreeNodeIndex = self.currentTreeNodes.firstIndex(where: { $0.source == courseSource })
        var courseChildrens = [newSectionTreeNode].compactMap { $0 }
        _ = self.createTreeNodeInTree(
            existingTreeNodeIndex: existingCourseTreeNodeIndex,
            source: courseSource,
            childrens: &courseChildrens,
            shouldReportProgress: cut.observationLevel >= .all,
            observer: observer
        )

        // Start downloading

        for (node, video) in videosForDownloading {
            // FIXME: VideosInfo
            let url = video.getUrlForQuality(VideosInfo.watchingVideoQuality)
            let taskID = self.videoDownloadingService.download(
                videoID: video.id,
                url: url
            )

            self.currentDownloads[taskID] = node
        }
    }

    /// Cancel unit/section/course downloading; target entity can be determined by observation level
    func stopDownloading(cut: SyllabusCut) {

    }

    /// Create new node in the tree and return reference to it;
    /// if node with given source already exists then return nil
    private func createTreeNodeInTree(
        existingTreeNodeIndex: Int?,
        source: DownloadSource,
        childrens: inout [DownloadTreeNode],
        shouldReportProgress: Bool,
        observer: @escaping DownloadTreeNode.Observer
    ) -> DownloadTreeNode? {
        if let index = existingTreeNodeIndex {
            // TreeNode exists in the tree, assign childrens
            self.currentTreeNodes[index].childrens.append(contentsOf: childrens)
            self.currentTreeNodes[index].shouldReportProgress = shouldReportProgress
            childrens.forEach { $0.parent = self.currentTreeNodes[index] }
        } else {
            // Insert node to the tree
            let node = DownloadTreeNode(
                source: source,
                childrens: childrens,
                shouldReportProgress: shouldReportProgress,
                observer: observer
            )

            self.currentTreeNodes.append(node)
            childrens.forEach { $0.parent = node }
            return node
        }

        return nil
    }

    /// Traverse tree from leaf to the root and mark all nodes as dirty (= needs to recalculate progress and completion status)
    private func markAsDirtyAllTree(node: DownloadTreeNode) {
        if let parent = node.parent {
            node.isDirty = true
            self.markAsDirtyAllTree(node: parent)
        }
    }

    /// Handle events from downloading service
    private func handleUpdate(event: VideoDownloadingServiceEvent) {
        guard let downloadTreeNode = self.currentDownloads[event.taskID] else {
            return
        }

        switch event.state {
        case .error:
            // Downloading failed, remove task and detach from parent
            downloadTreeNode.parent?.childrens.removeAll(where: { $0 === downloadTreeNode })
            downloadTreeNode.state = .finished(completed: false)
            self.markAsDirtyAllTree(node: downloadTreeNode)
            self.currentDownloads.removeValue(forKey: event.taskID)
        case .active(let progress):
            downloadTreeNode.state = .downloading(progress: progress)
            self.markAsDirtyAllTree(node: downloadTreeNode)
        case .completed(_):
            downloadTreeNode.state = .finished(completed: true)
            self.markAsDirtyAllTree(node: downloadTreeNode)
            self.currentDownloads.removeValue(forKey: event.taskID)
        }
    }

    /// Node representation in the syllabus tree
    private final class DownloadTreeNode {
        typealias Observer = (DownloadTreeNode) -> Void

        enum State {
            case finished(completed: Bool)
            case downloading(progress: Float)
        }

        /// Node type (e.g. step, unit, ...)
        let source: DownloadSource
        /// Node parent
        var parent: DownloadTreeNode?
        /// Node childrens
        var childrens: [DownloadTreeNode]

        private var observer: Observer?

        private var currentState: State = .downloading(progress: 0)

        /// Set true if should report progress
        var shouldReportProgress: Bool {
            didSet {
                if self.shouldReportProgress {
                    self.observer?(self)
                }
            }
        }

        /// Set true if some childrens were updated
        var isDirty = false {
            didSet {
                if self.isDirty && self.shouldReportProgress {
                    self.observer?(self)
                }
            }
        }

        /// Computed property of current node downloading progress;
        /// If node is marked as "dirty" then progress will be calculated recursive based on progresses of its child-nodes
        var state: State {
            get {
                if case .step(_) = self.source {
                    return self.currentState
                } else {
                    if self.isDirty {
                        self.updateProgressRecursive()
                        self.isDirty = false
                    }
                    return self.currentState
                }
            }
            set {
                if case .step(_) = self.source {
                    self.currentState = newValue
                }
            }
        }

        init(
            source: DownloadSource,
            childrens: [DownloadTreeNode],
            shouldReportProgress: Bool = false,
            observer: Observer? = nil
        ) {
            self.source = source
            self.childrens = childrens
            self.shouldReportProgress = shouldReportProgress
            self.observer = observer
        }

        private func updateProgressRecursive() {
            // If any children failed -> current node failed
            // If all childrens succeed -> current node succeed
            // Otherwise current node downloading

            let childrensDownloadingPercentage = self.childrens.map { children -> Float in
                switch children.state {
                case .downloading(let progress):
                    return progress
                case .finished(let completed):
                    return completed ? 1.0 : 0.0
                }
            }.reduce(0, +) / Float(self.childrens.count)

            let failedChildrensCount = self.childrens.map { children -> Int in
                switch children.state {
                case .downloading(_):
                    return 0
                case .finished(let completed):
                    return completed ? 0 : 1
                }
            }.reduce(0, +)

            let succeedChildrensCount = self.childrens.map { children -> Int in
                switch children.state {
                case .downloading(_):
                    return 0
                case .finished(let completed):
                    return completed ? 1 : 0
                }
            }.reduce(0, +)

            if failedChildrensCount > 0 {
                self.currentState = .finished(completed: false)
                return
            }

            if succeedChildrensCount == self.childrens.count {
                self.currentState = .finished(completed: true)
                return
            }

            self.currentState = .downloading(progress: childrensDownloadingPercentage)
        }
    }
}
