//
//  StepsViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit
import PromiseKit

final class StepsViewController: PagerController {

    // MARK: Instance Properties

    private let lesson: LessonPlainObject
    private var steps = [StepPlainObject]() {
        didSet {
            self.reloadData()
        }
    }

    private let stepsService: StepsService

    // MARK: - Init

    init(lesson: LessonPlainObject, stepsService: StepsService) {
        self.lesson = lesson
        self.stepsService = stepsService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        fetchSteps()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.showBottomHairline()
    }

    // MARK: - Overrides

    override func makeConstraints() {
        self.tabsView!.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.view)
            make.height.equalTo(44)
        }

        self.contentView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(self.view)
            make.top.equalTo(self.tabsView!.snp.bottom)
            make.bottom.equalTo(self.view)
        }

        let shadowView = UIView()
        self.contentView.addSubview(shadowView)
        shadowView.backgroundColor = .lightGray
        shadowView.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.top.equalTo(contentView)
            make.leading.trailing.equalTo(contentView)
        }
    }

    // MARK: - Private API -

    private func setup() {
        edgesForExtendedLayout = [.left, .right, .bottom]
        navigationController?.view.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.hideBottomHairline()

        view.backgroundColor = .white
        title = lesson.title

        setupTabs()
        dataSource = self
    }

    private func setupTabs() {
        indicatorColor = .mainDark
        tabsViewBackgroundColor = .white

        tabHeight = 44.0
        tabWidth = 44.0
        indicatorHeight = 2.0
        tabOffset = 8.0

        centerCurrentTab = true
        fixLaterTabsPosition = true
    }

    private func fetchSteps() {
        stepsService.fetchSteps(for: lesson).done { [weak self] steps in
            self?.steps = steps.filter { $0.type == .text }
        }.catch { error in
            print(error)
        }
    }
}

// MARK: - StepsViewController: PagerDataSource -

extension StepsViewController: PagerDataSource {
    public func numberOfTabs(_ pager: PagerController) -> Int {
        return steps.count
    }

    public func tabViewForIndex(_ index: Int, pager: PagerController) -> UIView {
        let step = steps[index]
        let frame = CGRect(origin: .zero, size: CGSize(width: 25, height: 25))

        return StepTabView(frame: frame, image: step.image, stepId: step.id, passed: false)
    }

    public func controllerForTabAtIndex(_ index: Int, pager: PagerController) -> UIViewController {
        return stepController(for: index)
    }

    // MARK: Private Helpers

    private func stepController(for index: Int) -> StepViewController {
        let controller = StepViewController()
        let presenter = StepPresenterImpl(
            view: controller,
            step: steps[index],
            lesson: lesson
        )
        controller.presenter = presenter

        return controller
    }
}

// MARK: - UINavigationBar+hideBottomHairline -

private extension UINavigationBar {
    func hideBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.isHidden = true
    }

    func showBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.isHidden = false
    }

    private func hairlineImageViewInNavigationBar(_ view: UIView) -> UIImageView? {
        if let view = view as? UIImageView, view.bounds.size.height <= 1.0 {
            return view
        }

        let subviews = (view.subviews as [UIView])
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInNavigationBar(subview) {
                return imageView
            }
        }

        return nil
    }
}
