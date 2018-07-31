//
//  StepsViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

final class StepsViewController: UIViewController {
    private let lesson: LessonPlainObject
    private var steps = [StepPlainObject]() {
        didSet {
            assert(Thread.isMainThread)
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }

    private let stepsService: StepsService

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self

        return tableView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(pullToRefresh(_:)), for: .valueChanged)

        return control
    }()

    init(lesson: LessonPlainObject, stepsService: StepsService) {
        self.lesson = lesson
        self.stepsService = stepsService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        print(lesson)

        title = lesson.title
        view.backgroundColor = .white

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.addSubview(refreshControl)

        fetchSteps()
    }

    @objc private func pullToRefresh(_ sender: Any) {
        fetchSteps()
    }

    private func fetchSteps() {
        stepsService.fetchSteps(for: lesson).done { [weak self] steps in
            self?.steps = steps
        }.catch { error in
            print(error)
        }
    }
}

extension StepsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return steps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(steps[indexPath.row].id)"

        return cell
    }
}

extension StepsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
