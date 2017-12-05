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
//    func updateBlock(block: [CourseListBlock])

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

    let supportedLanguages : [ContentLanguage] = [.russian, .english]

    init(view: ExploreView, courseListsAPI: CourseListsAPI, courseListsCache: CourseListsCache) {
        self.view = view
        self.courseListsAPI = courseListsAPI
        self.courseListsCache = courseListsCache
    }

    func initLanguagesWidget() {
        view?.setLanguages(withLanguages: supportedLanguages, initialLanguage: ContentLanguage.sharedContentLanguage, onSelected: {
            [weak self]
            selectedLanguage in
            if selectedLanguage != ContentLanguage.sharedContentLanguage {
                ContentLanguage.sharedContentLanguage = selectedLanguage
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
                controller.presenter = CourseListPresenter(
                    view: controller,
                    ID: "Tag_\(tag.ID)",
                    limit: nil,
                    listType:  CourseListType.tag(id: tag.ID) ,
                    colorMode: .light,
                    onlyLocal: false,
                    subscriptionManager: CourseSubscriptionManager(), coursesAPI: CoursesAPI(), progressesAPI: ProgressesAPI(), reviewSummariesAPI: CourseReviewSummariesAPI(), searchResultsAPI: SearchResultsAPI(), subscriber: CourseSubscriber()
                )
                controller.title = tag.titleForLanguage[ContentLanguage.sharedContentLanguage]
                self?.view?.show(vc: controller)
            }
        })
    }

    var searchController: NewSearchResultsViewController?

    func queryChanged(to query: String) {
        //TODO: Refactor this to router layer in the next releases
        if searchController == nil {
            guard let controller = ControllerHelper.instantiateViewController(identifier: "SearchResultsViewController", storyboardName: "Explore") as? NewSearchResultsViewController else {
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
        return CourseList.recover(ids: recoveredIds).sorted { $0.0.position < $0.1.position }
    }

    func refreshSync() {
        view?.setConnectionProblemsPlaceholder(hidden: true)
        let listLanguage = ContentLanguage.sharedContentLanguage
        refreshFromLocal(forLanguage: listLanguage)
        refreshFromRemote(forLanguage: listLanguage)
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
                fulfill()
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
        return newLists.map { $0.id } != lists.map { $0.id }
    }

    enum LanguageError: Error {
        case wrongLanguageError
    }

    private func refreshFromRemote(forLanguage language: ContentLanguage) {
        checkToken().then {
            [weak self]
            () -> Promise<([CourseList], Meta)> in
            guard let strongSelf = self else {
                throw WeakSelfError.noStrong
            }
            if ContentLanguage.sharedContentLanguage != language {
                throw LanguageError.wrongLanguageError
            }

            strongSelf.didRefreshOnce = true
            return strongSelf.courseListsAPI.retrieve(language: language, page: 1)
        }.then {
            [weak self]
            lists, _ -> Void in
            guard let strongSelf = self else {
                throw WeakSelfError.noStrong
            }
            if ContentLanguage.sharedContentLanguage != language {
                throw LanguageError.wrongLanguageError
            }

            strongSelf.courseListsCache.set(ids: lists.map { $0.id }, forLanguage: language)
            strongSelf.lists = lists.sorted { $0.0.position < $0.1.position }
            strongSelf.blocks = strongSelf.buildBlocks(forLists: strongSelf.lists, onlyLocal: false)
            strongSelf.view?.setConnectionProblemsPlaceholder(hidden: true)
            strongSelf.view?.presentBlocks(blocks: strongSelf.blocks)
        }.catch {
            [weak self]
            _ in
            guard let strongSelf = self else {
                return
            }
            //TODO: Also present popular block here if needed
            if strongSelf.lists.isEmpty {
                strongSelf.view?.setConnectionProblemsPlaceholder(hidden: false)
            }
            if !strongSelf.didRefreshOnce {
                strongSelf.setupNetworkReachabilityListener()
            }
            //TODO: Add Reachability observer here
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
