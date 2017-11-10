//
//  ExplorePresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

protocol ExploreView: class {
    func presentBlocks(blocks: [CourseListBlock])

    func show(vc: UIViewController)

//    func setLanguagesWidget()
//    func setTagsWidget()
    func updateCourseCount(to: Int, forBlockWithID: String)
}

class ExplorePresenter: CourseListCountDelegate {
    private weak var view: ExploreView?
    private var courseListsAPI: CourseListsAPI
    private var courseListsCache: CourseListsCache

    private var lists: [CourseList] = []
    private var blocks: [CourseListBlock] = []

    init(view: ExploreView, courseListsAPI: CourseListsAPI, courseListsCache: CourseListsCache) {
        self.view = view
        self.courseListsAPI = courseListsAPI
        self.courseListsCache = courseListsCache
    }

    private func getId(forList list: CourseList) -> String {
        return "collection_\(list.id)"
    }

    private func buildBlocks(forLists lists: [CourseList], onlyLocal: Bool) -> [CourseListBlock] {
        let showController: (UIViewController) -> Void = {
            [weak self]
            vc in
            self?.view?.show(vc: vc)
        }

        return lists.map {
            CourseListBlock(
                listType: .collection(ids: $0.coursesArray),
                ID: getId(forList: $0),
                horizontalLimit: 6,
                title: $0.title,
                colorMode: .light,
                shouldShowCount: true,
                showControllerBlock: showController,
                courseListCountDelegate: self,
                onlyLocal: onlyLocal
            )
        }
    }

    private func getCachedLists(forLanguage language: ContentLanguage) -> [CourseList] {
        let recoveredIds = courseListsCache.get(forLanguage: language)
        return CourseList.recover(ids: recoveredIds).sorted { $0.0.position < $0.1.position }
    }

    func refresh() {
        let listLanguage = ContentLanguage.sharedContentLanguage
        refreshFromLocal(forLanguage: listLanguage)
        refreshFromRemote(forLanguage: listLanguage)
    }

    private func refreshFromLocal(forLanguage language: ContentLanguage) {
        lists = getCachedLists(forLanguage: language)
        blocks = buildBlocks(forLists: lists, onlyLocal: true)
        view?.presentBlocks(blocks: blocks)
    }

    private func refreshFromRemote(forLanguage language: ContentLanguage) {
        checkToken().then {
            [weak self]
            () -> Promise<([CourseList], Meta)> in
            guard let strongSelf = self else {
                throw WeakSelfError.noStrong
            }
            return strongSelf.courseListsAPI.retrieve(language: language, page: 1)
        }.then {
            [weak self]
            lists, _ -> Void in
            guard let strongSelf = self else {
                throw WeakSelfError.noStrong
            }
            strongSelf.courseListsCache.set(ids: lists.map { $0.id }, forLanguage: language)
            strongSelf.lists = lists.sorted { $0.0.position < $0.1.position }
            strongSelf.blocks = strongSelf.buildBlocks(forLists: strongSelf.lists, onlyLocal: false)
            strongSelf.view?.presentBlocks(blocks: strongSelf.blocks)
        }.catch {
            [weak self]
            _ in
            guard let strongSelf = self else {
                return
            }

        }
    }

    func updateCourseCount(to: Int, forListID: String) {
        view?.updateCourseCount(to: to, forBlockWithID: forListID)
    }
}
