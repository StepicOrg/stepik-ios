import Foundation

enum AnnouncementStatus: String {
    case composing
    case scheduled
    case queueing
    case queued
    case sending
    case sent
    case aborted

    var isReady: Bool {
        let statuses: [AnnouncementStatus] = [.queueing, .queued, .sending, .sending]
        return statuses.contains(self)
    }

    var isInProgress: Bool {
        let statuses: [AnnouncementStatus] = [.queueing, .queued, .sending]
        return statuses.contains(self)
    }

    var isQueuedOrSending: Bool {
        let statuses: [AnnouncementStatus] = [.queued, .sending]
        return statuses.contains(self)
    }

    var isStopped: Bool {
        let statuses: [AnnouncementStatus] = [.scheduled, .sent, .aborted]
        return statuses.contains(self)
    }
}
