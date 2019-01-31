//
//  DataBackUpdateService.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 31/01/2019.
//  Copyright © 2019 Alex Karpov. All rights reserved.
//

import Foundation

enum DataBackUpdateTarget {
    case course(_: Course)
    case section(_: Section)
    case unit(_: Unit)

    case test
}

struct DataBackUpdateDescription: OptionSet {
    let rawValue: Int

    static let progress = DataBackUpdateDescription(rawValue: 1)
    static let enrollment = DataBackUpdateDescription(rawValue: 2)
}

protocol DataBackUpdateServiceDelegate: class {
    func dataBackUpdateService(
        _ dataBackUpdateService: DataBackUpdateService,
        reportUpdate update: DataBackUpdateDescription,
        for target: DataBackUpdateTarget
    )
}

protocol DataBackUpdateServiceProtocol: class {
    var delegate: DataBackUpdateServiceDelegate? { get set }

    /// Report about unit progress update
    func triggerProgressUpdate(for unit: Unit)
    /// Report about enrollment update for course
    func triggerEnrollmentUpdate(for course: Course)

    func triggerTest()
}

final class DataBackUpdateService: DataBackUpdateServiceProtocol {
    weak var delegate: DataBackUpdateServiceDelegate?

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.handleNotification(_:)),
            name: .dataBackUpdated,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Public methods

    func triggerProgressUpdate(for unit: Unit) {

    }

    func triggerEnrollmentUpdate(for course: Course) {

    }

    func triggerTest() {
        self.postNotification(
            name: .dataBackUpdated,
            description: [.progress, .enrollment],
            target: .test
        )
    }

    // MARK: Private methods

    private func postNotification(
        name: Foundation.Notification.Name,
        description: DataBackUpdateDescription,
        target: DataBackUpdateTarget
    ) {
        NotificationCenter.default.post(
            name: name,
            object: self,
            userInfo: [
                NotificationKey.description: description,
                NotificationKey.target: target
            ]
        )
    }

    @objc
    private func handleNotification(_ notification: Foundation.Notification) {
        guard let updateDescription = notification.userInfo?[NotificationKey.description] as? DataBackUpdateDescription,
              let updateTarget = notification.userInfo?[NotificationKey.target] as? DataBackUpdateTarget else {
            print("data back update service: received malformed notification")
            return
        }

        self.delegate?.dataBackUpdateService(self, reportUpdate: updateDescription, for: updateTarget)
    }

    private enum NotificationKey: String {
        case description
        case target
    }
}

private extension Foundation.Notification.Name {
    static let dataBackUpdated = NSNotification.Name("dataBackUpdated")
}
