//
//  DownloadTreeNodeTests.swift
//  StepicTests
//
//  Created by Vladislav Kiryukhin on 27/01/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import Foundation
import Nimble
import Quick
import XCTest
import Mockingjay
import SwiftyJSON

@testable import Stepic

private extension SyllabusTreeNode.Source {
    var id: Int {
        switch self {
        case .course(let id):
            return id
        case .section(let id):
            return id
        case .unit(let id):
            return id
        case .step(let id):
            return id
        case .video(let entity):
            return entity.id
        }
    }
}

final class DownloadTreeNodeSpec: QuickSpec {
    struct SyllabusTreeNodeFactory {
        private static var newID: Int = 0

        static var newUniqueID: Int {
            SyllabusTreeNodeFactory.newID += 1
            return SyllabusTreeNodeFactory.newID
        }

        static func makeVideo(id: Video.IdType) -> SyllabusTreeNode {
            // Now can construct Video only with JSON
            let json = JSON(parseJSON: "{\"id\": \"\(id)\", \"thumbnail\": \"\", \"urls\": []}")
            return SyllabusTreeNode(value: .video(entity: Video(json: json)))
        }

        static func makeStep(
            id: Step.IdType,
            videosIDs: [Video.IdType] = [SyllabusTreeNodeFactory.newUniqueID]
        ) -> SyllabusTreeNode {
            return SyllabusTreeNode(
                value: .step(id: id),
                children: videosIDs.map { SyllabusTreeNodeFactory.makeVideo(id: $0) }
            )
        }

        static func makeUnit(
            id: Stepic.Unit.IdType,
            stepsIDs: [Step.IdType] = [SyllabusTreeNodeFactory.newUniqueID]
        ) -> SyllabusTreeNode {
            return SyllabusTreeNode(
                value: .unit(id: id),
                children: stepsIDs.map { SyllabusTreeNodeFactory.makeStep(id: $0) }
            )
        }

        static func makeSection(
            id: Section.IdType,
            unitsIDs: [Stepic.Unit.IdType] = [SyllabusTreeNodeFactory.newUniqueID]
        ) -> SyllabusTreeNode {
            return SyllabusTreeNode(
                value: .section(id: id),
                children: unitsIDs.map { SyllabusTreeNodeFactory.makeUnit(id: $0) }
            )
        }

        static func makeCourse(
            id: Course.IdType,
            sectionsIDs: [Section.IdType] = [SyllabusTreeNodeFactory.newUniqueID]
        ) -> SyllabusTreeNode {
            return SyllabusTreeNode(
                value: .course(id: id),
                children: sectionsIDs.map { SyllabusTreeNodeFactory.makeSection(id: $0) }
            )
        }
    }

    override func spec() {
        describe("DownloadsTreeNode") {
            // Different cases

            // 1.   (s: 2)
            //      /    \
            //   (u: 5)  (u: 6)
            //     |       |
            //   (...)   (...)
            let downloadCase1 = SyllabusTreeNodeFactory.makeSection(id: 2, unitsIDs: [5, 6])

            // 2.      (c: 1)
            //         /    \
            //     (s: 2)  (s: 3)
            //     /   \        \
            //  (u: 5) (u: 6)  (u: 7)
            //     |      |       |
            //   (...)  (...)   (...)
            let downloadCase2 = SyllabusTreeNode(
                value: .course(id: 1),
                children: [
                    SyllabusTreeNodeFactory.makeSection(id: 2, unitsIDs: [5, 6]),
                    SyllabusTreeNodeFactory.makeSection(id: 3, unitsIDs: [7])
                ]
            )

            // 3.      (c: 1)
            //         /    \
            //     (s: 2)  (s: 3)
            //     /   \        \
            //  (u: 5) (u: 6)   (u: 7)
            //     |      |       |
            //  (s: 8) (s: 9)   (s: 10)
            //     |      |       |
            //  (v: 11) (v: 12) (v: 13)
            let downloadCase3 = SyllabusTreeNode(
                value: .course(id: 1),
                children: [
                    SyllabusTreeNode(
                        value: .section(id: 2),
                        children: [
                            SyllabusTreeNode(
                                value: .unit(id: 5),
                                children: [
                                    SyllabusTreeNodeFactory.makeStep(id: 8, videosIDs: [11])
                                ]
                            ),
                            SyllabusTreeNode(
                                value: .unit(id: 6),
                                children: [
                                    SyllabusTreeNodeFactory.makeStep(id: 9, videosIDs: [12])
                                ]
                            )
                        ]
                    ),
                    SyllabusTreeNode(
                        value: .section(id: 3),
                        children: [
                            SyllabusTreeNode(
                                value: .unit(id: 7),
                                children: [
                                    SyllabusTreeNodeFactory.makeStep(id: 10, videosIDs: [13])
                                ]
                            )
                        ]
                    )
                ]
            )

            // 4.      (s: 1)
            //         /    \
            //     (v: 2)  (v: 3)
            let downloadCase4 = SyllabusTreeNodeFactory.makeStep(id: 1, videosIDs: [2, 3])

            // 5.      (s: 4)
            //         /    \
            //     (v: 5)  (v: 6)
            let downloadCase5 = SyllabusTreeNodeFactory.makeStep(id: 4, videosIDs: [5, 6])

            describe("flattening") {
                context("when have valid flatten tree") {
                    it("contains nodes in correct NLR order") {
                        let tree = DownloadsTreeNode.makeDownloadsTreeNodeRecursive(syllabusSubtree: downloadCase3)

                        let flatTree = tree.flatten()
                        let flatTreeIDs = flatTree.map { $0.source.id }

                        let expectedIDsOrder = [1, 2, 5, 8, 11, 6, 9, 12, 3, 7, 10, 13]

                        expect(downloadCase3.isValid).to(beTrue())
                        expect(flatTreeIDs) == expectedIDsOrder
                    }
                }
            }

            describe("merge") {
                // Check `parent` references
                func checkParentReferences(node: DownloadsTreeNode, from: DownloadsTreeNode? = nil) {
                    if from == nil {
                        expect(node.parent).to(beNil())
                    } else {
                        expect(node.parent) === from
                    }
                    node.children.forEach { checkParentReferences(node: $0, from: node) }
                }

                func checkDownloadCase1AndDownloadCase2MergeResult(tree: DownloadsTreeNode) {
                    // Check values
                    expect(tree.source) == .course(id: 1)
                    expect(tree.children[0].source) == .section(id: 2)
                    expect(tree.children[1].source) == .section(id: 3)
                    expect(tree.children[0].children[0].source) == .unit(id: 5)
                    expect(tree.children[0].children[1].source) == .unit(id: 6)
                    expect(tree.children[0].children[0].children.count) == 2
                    expect(tree.children[0].children[0].children[0].children.count) == 1
                    expect(tree.children[0].children[1].children.count) == 2
                    expect(tree.children[0].children[1].children[0].children.count) == 1
                    expect(tree.children[1].children[0].source) == .unit(id: 7)
                    expect(tree.children[1].children[0].children.count) == 1
                    expect(tree.children[1].children[0].children[0].children.count) == 1

                    checkParentReferences(node: tree)
                }

                context("when merge two intersecting trees and second tree's root has observationLevel less than first") {
                    it("returns one correct merged tree") {
                        let firstTree = DownloadsTreeNode.makeDownloadsTreeNodeRecursive(syllabusSubtree: downloadCase1)
                        let secondTree = DownloadsTreeNode.makeDownloadsTreeNodeRecursive(syllabusSubtree: downloadCase2)

                        let mergedTrees = DownloadsTreeNode.tryToMerge(firstTree: firstTree, secondTree: secondTree)
                        expect(mergedTrees.count) == 1
                        checkDownloadCase1AndDownloadCase2MergeResult(tree: mergedTrees[0])
                    }
                }

                context("when merge two intersecting trees and second tree's root has observationLevel greater than first") {
                    it("returns one correct merged tree") {
                        let firstTree = DownloadsTreeNode.makeDownloadsTreeNodeRecursive(syllabusSubtree: downloadCase2)
                        let secondTree = DownloadsTreeNode.makeDownloadsTreeNodeRecursive(syllabusSubtree: downloadCase1)

                        let mergedTrees = DownloadsTreeNode.tryToMerge(firstTree: firstTree, secondTree: secondTree)
                        expect(mergedTrees.count) == 1
                        checkDownloadCase1AndDownloadCase2MergeResult(tree: mergedTrees[0])
                    }
                }

                context("when merge equal trees") {
                    it("returns one correct merged tree same as given") {
                        let firstTree = DownloadsTreeNode.makeDownloadsTreeNodeRecursive(syllabusSubtree: downloadCase4)
                        let secondTree = DownloadsTreeNode.makeDownloadsTreeNodeRecursive(syllabusSubtree: downloadCase4)

                        let mergedTrees = DownloadsTreeNode.tryToMerge(firstTree: firstTree, secondTree: secondTree)
                        expect(mergedTrees.count) == 1

                        let tree = mergedTrees[0]
                        expect(tree.source) == .step(id: 1)
                        expect(tree.children[0].source) == SyllabusTreeNodeFactory.makeVideo(id: 2).value
                        expect(tree.children[1].source) == SyllabusTreeNodeFactory.makeVideo(id: 3).value

                        checkParentReferences(node: tree)
                    }
                }

                context("when merge two non-intersecting trees") {
                    it("returns two given trees") {
                        let firstTree = DownloadsTreeNode.makeDownloadsTreeNodeRecursive(syllabusSubtree: downloadCase4)
                        let secondTree = DownloadsTreeNode.makeDownloadsTreeNodeRecursive(syllabusSubtree: downloadCase5)

                        let mergedTrees = DownloadsTreeNode.tryToMerge(firstTree: firstTree, secondTree: secondTree)
                        expect(mergedTrees.count) == 2

                        let tree1 = mergedTrees[0]
                        expect(tree1.source) == .step(id: 1)
                        expect(tree1.children[0].source) == SyllabusTreeNodeFactory.makeVideo(id: 2).value
                        expect(tree1.children[1].source) == SyllabusTreeNodeFactory.makeVideo(id: 3).value

                        checkParentReferences(node: tree1)

                        let tree2 = mergedTrees[1]
                        expect(tree2.source) == .step(id: 4)
                        expect(tree2.children[0].source) == SyllabusTreeNodeFactory.makeVideo(id: 5).value
                        expect(tree2.children[1].source) == SyllabusTreeNodeFactory.makeVideo(id: 6).value

                        checkParentReferences(node: tree2)
                    }
                }
            }
        }
    }
}
