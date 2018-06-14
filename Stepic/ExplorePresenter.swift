//
//  ExplorePresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.11.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire

protocol ExploreView: class {
    func presentBlocks(blocks: [CourseListBlock])
    func updateBlock(withID: String, newListType: CourseListType, onlyLocal: Bool)
    func updateBlock(withID: String, onlyLocal: Bool)
    func updateBlock(withID: String, newTitle: String, newDescription: String?)

    func setConnectionProblemsPlaceholder(hidden: Bool)

    func setLanguages(withLanguages: [ContentLanguage], initialLanguage: ContentLanguage, onSelected: @escaping (ContentLanguage) -> Void)

    func setTags(withTags: [CourseTag], language: ContentLanguage, onSelected: @escaping (CourseTag) -> Void)
    func updateTagsLanguage(language: ContentLanguage)

    func updateCourseCount(to: Int, forBlockWithID: String)
    func updateSearchQuery(to: String)

    func hideKeyboard()

    func show(vc: UIViewController)
    func setSearch(vc: UIViewController)
    func setSearch(hidden: Bool)
}

class ExplorePresenter: CourseListCountDelegate {
    private weak var view: ExploreView?
    private var courseListsAPI: CourseListsAPI
    private var courseListsCache: CourseListsCache

    private var lists: [CourseList] = []
    private var blocks: [CourseListBlock] = []
    private var didRefreshOnce: Bool = false

    private var currentLanguage: ContentLanguage = ContentLanguage.sharedContentLanguage

    init(view: ExploreView, courseListsAPI: CourseListsAPI, courseListsCache: CourseListsCache) {
        self.view = view
        self.courseListsAPI = courseListsAPI
        self.courseListsCache = courseListsCache
    }

    func willAppear() {
        DefaultsContainer.explore.shouldDisplayContentLanguageWidget = false
        if currentLanguage != ContentLanguage.sharedContentLanguage {
            currentLanguage = ContentLanguage.sharedContentLanguage
            view?.updateTagsLanguage(language: currentLanguage)
            refresh()
        }
    }

    func initLanguagesWidget() {
        view?.setLanguages(withLanguages: ContentLanguage.supportedLanguages, initialLanguage: ContentLanguage.sharedContentLanguage, onSelected: {
            [weak self]
            selectedLanguage in
            if selectedLanguage != ContentLanguage.sharedContentLanguage {
                ContentLanguage.sharedContentLanguage = selectedLanguage
                self?.currentLanguage = selectedLanguage
                self?.view?.updateTagsLanguage(language: selectedLanguage)
                self?.refresh()
            }
        })
    }

    func initTagsWidget() {
        view?.setTags(withTags: CourseTag.featuredTags, language: ContentLanguage.sharedContentLanguage, onSelected: {
            [weak self]
            tag in
            if let controller = ControllerHelper.instantiateViewController(identifier: "CourseListVerticalViewController", storyboardName: "CourseLists") as? CourseListVerticalViewController {
                controller.colorMode = .light
                controller.presenter = CourseListPresenter(
                    view: controller,
                    id: "Tag_\(tag.ID)",
                    limit: nil,
                    listType:  CourseListType.tag(id: tag.ID) ,
                    onlyLocal: false,
                    subscriptionManager: CourseSubscriptionManager(), coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI(), reviewSummariesAPI: CourseReviewSummariesAPI(), searchResultsAPI: SearchResultsAPI(), subscriber: CourseSubscriber(), adaptiveStorageManager: AdaptiveStorageManager()
                )
                controller.title = tag.titleForLanguage[ContentLanguage.sharedContentLanguage]
                self?.view?.show(vc: controller)
            }
        })
    }

    var searchController: SearchResultsViewController?

    func queryChanged(to query: String) {
        //TODO: Refactor this to router layer in the next releases
        if searchController == nil {
            guard let controller = ControllerHelper.instantiateViewController(identifier: "SearchResultsViewController", storyboardName: "Explore") as? SearchResultsViewController else {
                return
            }
            searchController = controller
            controller.presenter = SearchResultsPresenter(view: controller)
            controller.presenter?.hideKeyboardBlock = {
                [weak self] in
                self?.view?.hideKeyboard()
            }
            controller.presenter?.updateQueryBlock = {
                [weak self]
                newQuery in
                self?.view?.updateSearchQuery(to: newQuery)
            }
            view?.setSearch(vc: controller)
        }
        searchController?.presenter?.queryChanged(to: query)
        view?.setSearch(hidden: false)
    }

    func search(query: String) {
        searchController?.presenter?.search(query: query)
    }

    func searchStarted() {
        if searchController == nil {
            queryChanged(to: "")
        } else {
            searchController?.presenter?.searchStarted()
        }
    }

    func searchCancelled() {
        view?.setSearch(hidden: true)
        searchController?.presenter?.searchCancelled()
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

        return
            lists.map {
                CourseListBlock(
                    listType: .collection(ids: $0.coursesArray),
                    ID: getId(forList: $0),
                    horizontalLimit: 14,
                    title: $0.title,
                    description: $0.listDescription,
                    colorMode: .light,
                    shouldShowCount: true,
                    showControllerBlock: showController,
                    courseListCountDelegate: self,
                    onlyLocal: onlyLocal,
                    descriptionColorStyle: $0.id % 2 == 0 ? .pink : .blue
                )
            } +
            [
                CourseListBlock(
                    listType: .popular,
                    ID: "Popular",
                    horizontalLimit: 14,
                    title: NSLocalizedString("Popular", comment: ""),
                    colorMode: .dark,
                    shouldShowCount: false,
                    showControllerBlock: showController
                )
            ]
    }

    private func getCachedListsAsync(forLanguage language: ContentLanguage) -> Promise<[CourseList]> {
        let recoveredIds = courseListsCache.get(forLanguage: language)
        return CourseList.recoverAsync(ids: recoveredIds)
    }

    private func getCachedLists(forLanguage language: ContentLanguage) -> [CourseList] {
        let recoveredIds = courseListsCache.get(forLanguage: language)
        return CourseList.recover(ids: recoveredIds).sorted { $0.position < $1.position }
    }

    func refresh() {
        view?.setConnectionProblemsPlaceholder(hidden: true)
        let listLanguage = ContentLanguage.sharedContentLanguage
        refreshFromLocalAsync(forLanguage: listLanguage).then {
            [weak self] in
            self?.refreshFromRemote(forLanguage: listLanguage)
        }
    }

    private func refreshFromLocalAsync(forLanguage language: ContentLanguage) -> Promise<Void> {
        return Promise {
            fulfill, reject in
            getCachedListsAsync(forLanguage: language).then {
                [weak self]
                lists -> Void in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.lists = lists
                strongSelf.blocks = strongSelf.buildBlocks(forLists: lists, onlyLocal: true)
                strongSelf.view?.presentBlocks(blocks: strongSelf.blocks)
                fulfill(())
            }.catch {
                error in
                reject(error)
            }
        }
    }

    private func refreshFromLocal(forLanguage language: ContentLanguage) {
        lists = getCachedLists(forLanguage: language)
        blocks = buildBlocks(forLists: lists, onlyLocal: true)
        view?.presentBlocks(blocks: blocks)
    }

    private func shouldReloadAll(newLists: [CourseList]) -> Bool {
        return newLists.map { getId(forList: $0) } != blocks.flatMap {
            switch $0.listType {
            case .collection(ids: _):
                return $0.ID
            default:
                return nil
            }
        }
    }

    enum LanguageError: Error {
        case wrongLanguageError
    }

    private func updateLists(newLists: [CourseList], forLanguage language: ContentLanguage) {
        func refreshLists() {
            lists = newLists
            blocks = buildBlocks(forLists: lists, onlyLocal: false)
            view?.setConnectionProblemsPlaceholder(hidden: true)
            view?.presentBlocks(blocks: blocks)
        }
        courseListsCache.set(ids: newLists.map { $0.id }, forLanguage: language)

        if shouldReloadAll(newLists: newLists) {
            refreshLists()
            return
        }

        for newList in newLists {
            guard let blockForList: CourseListBlock = blocks.first(where: {
                $0.ID == getId(forList: newList)
            }) else {
                refreshLists()
                return
            }

            let ID = getId(forList: newList)
            if newList.coursesArray != blockForList.coursesIDs {
                view?.updateBlock(withID: ID, newListType: CourseListType.collection(ids: newList.coursesArray), onlyLocal: false)
            } else {
                view?.updateBlock(withID: ID, onlyLocal: false)
            }
            if newList.title != blockForList.title || newList.listDescription != blockForList.description {
                view?.updateBlock(withID: ID, newTitle: newList.title, newDescription: newList.listDescription)
            }
        }
    }

    private func refreshFromRemote(forLanguage language: ContentLanguage) {
        didRefreshOnce = true
        courseListsAPI.retrieve(language: language, page: 1).then {
            [weak self]
            lists, _ -> Void in
            guard let strongSelf = self else {
                throw UnwrappingError.optionalError
            }
            if ContentLanguage.sharedContentLanguage != language {
                throw LanguageError.wrongLanguageError
            }
            let newLists = lists.sorted { $0.position < $1.position }
            strongSelf.updateLists(newLists: newLists, forLanguage: language)
        }.catch {
            [weak self]
            _ in
            guard let strongSelf = self else {
                return
            }
            if strongSelf.lists.isEmpty {
                strongSelf.view?.setConnectionProblemsPlaceholder(hidden: false)
            }
            if !strongSelf.didRefreshOnce {
                strongSelf.setupNetworkReachabilityListener()
            }
        }
    }

    private var reachabilityManager: Alamofire.NetworkReachabilityManager?
    private func setupNetworkReachabilityListener() {
        guard reachabilityManager == nil else {
            return
        }
        reachabilityManager = Alamofire.NetworkReachabilityManager(host: StepicApplicationsInfo.stepicURL)
        reachabilityManager?.listener = {
            [weak self]
            status in
            guard let strongSelf = self else {
                return
            }
            if !strongSelf.didRefreshOnce {
                switch status {
                case .reachable(_):
                    strongSelf.refresh()
                default:
                    break
                }
            }
        }
        reachabilityManager?.startListening()
    }

    func updateCourseCount(to: Int, forListID: String) {
        view?.updateCourseCount(to: to, forBlockWithID: forListID)
    }
}

enum SearchState {
    case noSearch, suggestions, results
}
