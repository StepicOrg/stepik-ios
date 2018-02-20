//
//  AdaptiveCourseSelectViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.02.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import UPCarouselFlowLayout

enum AdaptiveCourseSelectViewState {
    case loading, normal, error
}

class AdaptiveCourseSelectViewController: UIViewController, AdaptiveCourseSelectView {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingContainerView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!

    var data: [AdaptiveCourseSelectViewData] = []
    var didControllerDisplayBefore = false

    lazy var placeholderView: PlaceholderView = {
        let v = PlaceholderView()
        self.view.insertSubview(v, aboveSubview: self.view)
        v.align(toView: self.view)
        v.delegate = self
        v.backgroundColor = self.view.backgroundColor
        return v
    }()

    var presenter: AdaptiveCourseSelectPresenter?
    var state: AdaptiveCourseSelectViewState = .normal {
        didSet {
            switch state {
            case .normal:
                self.placeholderView.isHidden = true
                self.tableView.isHidden = false
                self.loadingContainerView.isHidden = true
            case .error:
                self.placeholderView.isHidden = false
                self.tableView.isHidden = true
                self.loadingContainerView.isHidden = true

                // Refresh placeholder state
                self.placeholderView.datasource = self
            case .loading:
                self.placeholderView.isHidden = true
                self.tableView.isHidden = true
                self.loadingContainerView.isHidden = false
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadingLabel.text = NSLocalizedString("AdaptiveCourseSelectLoading", comment: "")

        title = "Select course"
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

extension AdaptiveCourseSelectViewController: PlaceholderViewDataSource {
    func placeholderImage() -> UIImage? {
        switch state {
        case .error:
            return Images.placeholders.connectionError
        default:
            return nil
        }
    }

    func placeholderButtonTitle() -> String? {
        switch state {
        case .error:
            return NSLocalizedString("TryAgain", comment: "")
        default:
            return nil
        }
    }

    func placeholderDescription() -> String? {
        switch state {
        case .error:
            return nil
        default:
            return nil
        }
    }

    func placeholderStyle() -> PlaceholderStyle {
        var style = PlaceholderStyle()
        style.button.textColor = UIColor.mainDark
        return style
    }

    func placeholderTitle() -> String? {
        switch state {
        case .error:
            return NSLocalizedString("ConnectionErrorText", comment: "")
        default:
            return nil
        }
    }
}

extension AdaptiveCourseSelectViewController: PlaceholderViewDelegate {
    func placeholderButtonDidPress() {
        presenter?.tryAgain()
    }
}
