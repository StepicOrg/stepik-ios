//
//  CompilationCollectionPresenter.swift
//  StepikTV
//
//  Created by Anton Kondrashov on 25/11/2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit

class CompilationCollectionPresenter {

    let courseAPI = CoursesAPI()

    private weak var view: CompilationCollectionView?
    private var courseListsAPI: CourseListsAPI
    private var courseListsCache: CourseListsCache

    private var lists: [CourseList] = []
    private var loaders: [CollectionRowLoader] = []
    private var rows: [CollectionRow] = []

    init(view: CompilationCollectionView, courseListsAPI: CourseListsAPI, courseListsCache: CourseListsCache) {
        self.view = view
        self.courseListsAPI = courseListsAPI
        self.courseListsCache = courseListsCache
    }

    func refresh() {
        //view?.setConnectionProblemsPlaceholder(hidden: true)
        let listLanguage = ContentLanguage.sharedContentLanguage
        refreshFromRemote(forLanguage: listLanguage)
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

                strongSelf.lists = lists.sorted { $0.0.position < $0.1.position }
                strongSelf.loaders = [
                    CollectionRowLoader(listType: .popular, title: "Popular"),
                    CollectionRowLoader(title: "Subjects")
                    ] + lists.map { CollectionRowLoader(listType: .collection(ids: $0.coursesArray), title: $0.title) }

                strongSelf.rows = strongSelf.loaders.map { strongSelf.buildRow(from: $0) }
                strongSelf.view?.setup(with: strongSelf.rows)

                for (index, loader) in strongSelf.loaders.enumerated() {
                  loader.getCourses(withAPI: strongSelf.courseAPI)?.then {
                        [weak self]
                        courses -> Void in
                        guard let strongSelf = self else {
                            throw WeakSelfError.noStrong
                        }

                    strongSelf.rows[index].setData(with: courses, for: strongSelf.view as? UIViewController)
                        strongSelf.view?.update(rowWith: index)
                    }.catch {
                        [weak self]
                        _ in
                        print("Error while refreshing collection")
                    }

                    loader.getPopular(withAPI: strongSelf.courseAPI, language: language)?.then {
                        [weak self]
                        (courses, _) -> Void in
                        guard let strongSelf = self else {
                            throw WeakSelfError.noStrong
                        }

                        strongSelf.rows[index].setData(with: courses, for: strongSelf.view as? UIViewController)
                        strongSelf.view?.update(rowWith: index)
                    }.catch {
                        [weak self]
                        _ in
                        print("Error while refreshing collection")
                    }

                    if let tags = loader.getTags() {
                        strongSelf.rows[index].setData(with: tags, language: language, for: strongSelf.view as? UIViewController)
                        strongSelf.view?.update(rowWith: index)
                    }
                }
        }.catch {
            [weak self]
            error in
            guard let _ = self else { return }
            print(error.localizedDescription)
        }
    }

    private func buildRow(from loader: CollectionRowLoader) -> CollectionRow {
        guard let listType = loader.listType else { return CollectionRow(.narrow(title: loader.title)) }

        switch listType {
        case let .collection(ids: ids):
            return CollectionRow(.regular(title: loader.title), count: ids.count)
        case .popular:
            return CollectionRow(.major)
        default:
            fatalError()
        }
    }
}

struct CollectionRowLoader {
    var listType: CourseListType?
    let title: String

    init(title: String) {
        self.title = title
    }

    init(listType: CourseListType, title: String) {
        self.title = title
        self.listType = listType
    }

    func getCourses(withAPI coursesAPI: CoursesAPI) -> Promise<[Course]>? {
        guard let listType = listType else { return nil }

        switch listType {
        case let .collection(ids: ids):
            return listType.request(coursesWithIds: ids, withAPI: coursesAPI)
        default:
            return nil
        }
    }

    func getPopular(withAPI coursesAPI: CoursesAPI, language: ContentLanguage) -> Promise<([Course], Meta)>? {
        guard let listType = listType else { return nil }

        switch listType {
        case .popular:
            return coursesAPI.retrieve(excludeEnded: true, isPublic: true, order: "-activity", language: language, page: 1)
        default:
            return nil
        }
    }

    func getTags() -> [CourseTag]? {
        if listType == nil { return CourseTag.featuredTags }

        return nil
    }
}

enum CollectionRowType {
    case major
    case regular(title: String)
    case narrow(title: String)

    var viewClass: CollectionRowView.Type {
        switch self {
        case .major:
            return MajorCollectionRowViewCell.self
        case .regular:
            return RegularCollectionRowViewCell.self
        case .narrow:
            return NarrowCollectionRowViewCell.self
        }
    }
}

class CollectionRow {
    let title: String?
    let count: Int
    let type: CollectionRowType

    var loaded: Bool = false

    init(_ type: CollectionRowType, count: Int = 5) {
        self.type = type
        self.count = count

        switch type {
        case let .regular(title: title):
            self.title = title
            data = [ItemViewData](repeating: ItemViewData(placeholder: #imageLiteral(resourceName: "placeholder")), count: count)
        case let .narrow(title: title):
            self.title = title
            data = [ItemViewData](repeating: ItemViewData(placeholder: #imageLiteral(resourceName: "tag-placeholder")), count: count)
        default:
            self.title = nil
            data = [ItemViewData](repeating: ItemViewData(placeholder: #imageLiteral(resourceName: "placeholder")), count: count)
        }
    }

    private(set) var data: [ItemViewData] = []

    func setData(with tags: [CourseTag], language: ContentLanguage, for viewController: UIViewController?) {
        data = tags.map {
            ItemViewData(placeholder: #imageLiteral(resourceName: "tag-placeholder"), title: $0.titleForLanguage[language]!, viewController: viewController) {

            }
        }

        loaded = true
    }

    func setData(with courses: [Course], for viewController: UIViewController?) {
        data = courses.map { course in
            ItemViewData(placeholder: #imageLiteral(resourceName: "placeholder"), imageURLString: course.coverURLString, title: course.title, subtitle: "Higher School of Economics", viewController: viewController) {

                let courseInfoVC = ControllerHelper.instantiateViewController(identifier: "CourseInfoCollectionViewController", storyboardName: "CourseInfo") as! CourseInfoCollectionViewController

                courseInfoVC.presenter = CourseInfoPresenter(view: courseInfoVC)
                courseInfoVC.presenter?.course = course

                viewController?.present(courseInfoVC, animated: true, completion: {})
            }
        }

        loaded = true
    }
}

struct ItemViewData {
    let title: String
    var subtitle: String?
    var action: (() -> Void)?
    weak var viewController: UIViewController?

    let placeholder: UIImage
    var backgroundImageURL: URL?

    var isEmpty: Bool = false

    init(placeholder: UIImage) {
        isEmpty = true

        title = ""
        self.placeholder = placeholder
    }

    init(placeholder: UIImage, title: String, subtitle: String? = nil, viewController: UIViewController?, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.viewController = viewController

        self.placeholder = placeholder
    }

    init(placeholder: UIImage, imageURLString: String, title: String, subtitle: String? = nil, viewController: UIViewController?, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.viewController = viewController

        self.placeholder = placeholder
        self.backgroundImageURL = URL(string: imageURLString)
    }
}
