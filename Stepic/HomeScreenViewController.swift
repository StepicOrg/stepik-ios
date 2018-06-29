//
//  HomeScreenViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 25.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import SnapKit

class HomeScreenViewController: UIViewController, HomeScreenView {
    var presenter: HomeScreenPresenter?

    var scrollView: UIScrollView = UIScrollView()
    var stackView: UIStackView = UIStackView()

    var blocks: [CourseListBlock] = []
    var countForID: [String: Int] = [:]
    var countUpdateBlock: [String: () -> Void] = [:]

    private let continueLearningWidget = ContinueLearningWidgetView(frame: CGRect.zero)
    private var isContinueLearningWidgetPresented: Bool = false
    private let widgetBackgroundView = UIView()

    private let streaksWidgetBackgroundView = UIView()
    private var streaksWidgetView: UserActivityHomeView?

    private var continueLearningTooltip: Tooltip?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter = HomeScreenPresenter(view: self, userActivitiesAPI: UserActivitiesAPI())
        setupStackView()
        presenter?.initBlocks()
        self.title = NSLocalizedString("Home", comment: "")
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter?.checkStreaks()
        isOnScreen = true
        viewWillAppearBlock?()
    }

    var isOnScreen: Bool = false
    var viewWillAppearBlock: (() -> Void)?

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        continueLearningTooltip?.dismiss()
        isOnScreen = false
    }

    private func setupStackView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        scrollView.align(toView: self.view)
        scrollView.snp.makeConstraints { $0.edges.equalTo(self.view) }

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { $0.edges.equalTo(scrollView) }
        stackView.alignment = .fill
    }

    private func reload() {
        for block in blocks {
            let courseListView: HorizontalCoursesView = HorizontalCoursesView(frame: CGRect.zero)
            self.addChildViewController(block.horizontalController)
            courseListView.setup(block: block)
            countUpdateBlock[block.ID] = {
                [weak self] in
                guard let strongSelf = self else {
                    return
                }
                courseListView.courseCount = strongSelf.countForID[block.ID] ?? 0
            }
            if let count = countForID[block.ID] {
                courseListView.courseCount = count
            }
            stackView.addArrangedSubview(courseListView)
            courseListView.alignLeading("0", trailing: "0", toView: self.view)
        }
    }

    func presentBlocks(blocks: [CourseListBlock]) {
        self.blocks = blocks
        reload()
    }

    func getNavigation() -> UINavigationController? {
        return self.navigationController
    }

    func updateCourseCount(to count: Int, forBlockWithID ID: String) {
        countForID[ID] = count
        countUpdateBlock[ID]?()
    }

    func show(vc: UIViewController) {
        self.show(vc, sender: nil)
    }

    func presentStreaksInfo(streakCount: Int, shouldSolveToday: Bool) {
        if streaksWidgetView == nil {
            let widget = UserActivityHomeView(frame: CGRect.zero)
            streaksWidgetView = widget
            streaksWidgetBackgroundView.backgroundColor = UIColor.white
            streaksWidgetBackgroundView.addSubview(widget)
            widget.alignTop("16", bottom: "-8", toView: streaksWidgetBackgroundView)
            if #available(iOS 11.0, *) {
                NSLayoutConstraint.activate([
                    widget.leadingAnchor.constraint(equalTo: streaksWidgetBackgroundView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                    widget.trailingAnchor.constraint(equalTo: streaksWidgetBackgroundView.safeAreaLayoutGuide.trailingAnchor, constant: -16)
                ])
            } else {
                widget.alignLeading("16", trailing: "-16", toView: streaksWidgetBackgroundView)
            }
            widget.setRoundedCorners(cornerRadius: 8)
            streaksWidgetBackgroundView.isHidden = true
            stackView.insertArrangedSubview(streaksWidgetBackgroundView, at: 0)
            streaksWidgetBackgroundView.alignLeading("0", trailing: "0", toView: self.view)
        }

        streaksWidgetView?.set(streakCount: streakCount, shouldSolveToday: shouldSolveToday)

        UIView.animate(withDuration: 0.15) {
            self.streaksWidgetBackgroundView.isHidden = false
        }
    }

    func hideStreaksInfo() {
        streaksWidgetBackgroundView.isHidden = true
    }

    func presentContinueLearningWidget(widgetData: ContinueLearningWidgetData) {
        continueLearningWidget.setup(widgetData: widgetData)

        widgetBackgroundView.backgroundColor = UIColor.white
        widgetBackgroundView.addSubview(continueLearningWidget)
        continueLearningWidget.alignTop("16", bottom: "-8", toView: widgetBackgroundView)
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                continueLearningWidget.leadingAnchor.constraint(equalTo: widgetBackgroundView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                continueLearningWidget.trailingAnchor.constraint(equalTo: widgetBackgroundView.safeAreaLayoutGuide.trailingAnchor, constant: -16)
                ])
        } else {
            continueLearningWidget.alignLeading("16", trailing: "-16", toView: widgetBackgroundView)
        }
        continueLearningWidget.setRoundedCorners(cornerRadius: 8)
        widgetBackgroundView.isHidden = true
        stackView.insertArrangedSubview(widgetBackgroundView, at: streaksWidgetView == nil ? 0 : 1)
        widgetBackgroundView.alignLeading("0", trailing: "0", toView: self.view)

        UIView.animate(withDuration: 0.15, animations: {
            self.widgetBackgroundView.isHidden = false
        }, completion: {
            _ in
            if TooltipDefaultsManager.shared.shouldShowOnHomeContinueLearning {
                self.viewWillAppearBlock = {
                    [weak self] in
                    guard let strongSelf = self else {
                        return
                    }
                    strongSelf.continueLearningTooltip = TooltipFactory.continueLearningWidget
                    strongSelf.continueLearningTooltip?.show(direction: .up, in: strongSelf.continueLearningWidget, from: strongSelf.continueLearningWidget.continueLearningButton)
                    TooltipDefaultsManager.shared.didShowOnHomeContinueLearning = true
                    strongSelf.viewWillAppearBlock = nil
                }
                if self.isOnScreen {
                    self.viewWillAppearBlock?()
                }
            }
        })

        if !isContinueLearningWidgetPresented {
            isContinueLearningWidgetPresented = true
        }
    }

    func hideCountinueLearningWidget() {
        isContinueLearningWidgetPresented = false
        stackView.removeArrangedSubview(widgetBackgroundView)
        continueLearningTooltip?.dismiss()
        UIView.animate(withDuration: 0.15) {
            self.widgetBackgroundView.isHidden = true
        }
    }
}
