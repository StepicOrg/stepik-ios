//
//  TagsTagsViewController.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol TagsViewControllerProtocol: class {
    func displayTags(viewModel: Tags.ShowTags.ViewModel)
}

final class TagsViewController: UIViewController {
    let interactor: TagsInteractorProtocol
    private var state: Tags.ViewControllerState

    private let tagsDelegate: TagsCollectionViewDelegate
    private let tagsDataSource: TagsCollectionViewDataSource

    lazy var tagsView = self.view as? TagsView

    init(
        interactor: TagsInteractorProtocol,
        initialState: Tags.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState

        self.tagsDelegate = TagsCollectionViewDelegate()
        self.tagsDataSource = TagsCollectionViewDataSource()

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        let view = TagsView(
            frame: UIScreen.main.bounds,
            delegate: self.tagsDelegate,
            dataSource: self.tagsDataSource
        )
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshTags()
    }

    // MARK: Requests logic

    private func refreshTags() {
        self.interactor.fetchTags(request: Tags.ShowTags.Request())
    }
}

extension TagsViewController: TagsViewControllerProtocol {
    func displayTags(viewModel: Tags.ShowTags.ViewModel) {
        switch viewModel.state {
        case .result(let data):
            self.tagsDataSource.viewModels = data
            self.tagsView?.updateCollectionViewData(
                delegate: self.tagsDelegate,
                dataSource: self.tagsDataSource
            )
        default:
            break
        }
    }
}
