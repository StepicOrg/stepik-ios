//
// Created by Ivan Magda on 06/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation

extension Foundation.NotificationCenter {
    func addObserver<A>(descriptor: NotificationDescriptor<A>, queue: OperationQueue? = nil, using block: @escaping (A) -> Void) -> NotificationToken {
        let token = addObserver(forName: descriptor.name, object: nil, queue: queue) { notification in
            block(descriptor.convert(notification))
        }

        return NotificationToken(token: token, center: self)
    }

    func addObserver<A>(descriptor: ObjectNotificationDescriptor<A>, queue: OperationQueue? = nil, using block: @escaping (A) -> Void) -> NotificationToken {
        let token = addObserver(forName: descriptor.name, object: nil, queue: queue) { note in
            block(note.object as! A)
        }

        return NotificationToken(token: token, center: self)
    }

    func post<A>(descriptor: ObjectNotificationDescriptor<A>, value: A) {
        post(name: descriptor.name, object: value)
    }
}
