//
//  AdaptiveCourseSelectViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.02.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

enum AdaptiveCourseSelectViewState {
    case loading, normal, error
}

extension StepikPlaceholder.Style {
    static let noConnectionAdaptive = StepikPlaceholderStyle(id: "noConnectionAdaptive",
                                         image: nil,
                                         text: NSLocalizedString("PlaceholderNoConnectionText", comment: ""),
                                         buttonTitle: NSLocalizedString("PlaceholderNoConnectionButton", comment: ""))
}

class AdaptiveCourseSelectViewController: UIViewController, AdaptiveCourseSelectView, ControllerWithStepikPlaceholder {
    var placeholderContainer: StepikPlaceholderControllerContainer = StepikPlaceholderControllerContainer()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingContainerView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!

    var data: [AdaptiveCourseSelectViewData] = []
    var didControllerDisplayBefore = false

    var presenter: AdaptiveCourseSelectPresenter?
    var state: AdaptiveCourseSelectViewState = .normal {
        didSet {
            switch state {
            case .normal:
                isPlaceholderShown = false
                self.tableView.isHidden = false
                self.loadingContainerView.isHidden = true
            case .error:
                showPlaceholder(for: .connectionError)
                self.tableView.isHidden = true
                self.loadingContainerView.isHidden = true
            case .loading:
                isPlaceholderShown = false
                self.tableView.isHidden = true
                self.loadingContainerView.isHidden = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        registerPlaceholder(placeholder: StepikPlaceholder(.noConnectionAdaptive, action: { [weak self] in
            self?.presenter?.tryAgain()
        }), for: .connectionError)

        loadingLabel.text = NSLocalizedString("AdaptiveCourseSelectLoading", comment: "")

        title = NSLocalizedString("AdaptiveCourseSelectTitle", comment: "")
        tableView.register(UINib(nibName: "AdaptiveCourseTableViewCell", bundle: nil), forCellReuseIdentifier: AdaptiveCourseTableViewCell.reuseId)

        presenter?.refresh()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presenter?.refreshProgresses()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func set(data: [AdaptiveCourseSelectViewData]) {
        self.data = data
        tableView.reloadData()
    }

    func presentCourse(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)

        if didControllerDisplayBefore {
            // View controller will appear at second time
            presenter?.resetLastCourse()
        } else {
            didControllerDisplayBefore = true
        }
    }
}

extension AdaptiveCourseSelectViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AdaptiveCourseTableViewCell.reuseId, for: indexPath) as! AdaptiveCourseTableViewCell
        cell.setData(imageLink: data[indexPath.row].cover, name: data[indexPath.row].name, description: data[indexPath.row].description, learners: data[indexPath.row].learners, points: data[indexPath.row].points, level: data[indexPath.row].level)
        cell.updateColors(firstColor: data[indexPath.row].firstColor, secondColor: data[indexPath.row].secondColor)
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let courseId = data[indexPath.row].id
        presenter?.openCourse(id: courseId, uiColor: data[indexPath.row].mainColor)
    }
}

extension AdaptiveCourseSelectViewController: AdaptiveCourseTableViewCellDelegate {
    func buttonDidClick(_ cell: AdaptiveCourseTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }

        tableView(tableView, didSelectRowAt: indexPath)
    }
}
