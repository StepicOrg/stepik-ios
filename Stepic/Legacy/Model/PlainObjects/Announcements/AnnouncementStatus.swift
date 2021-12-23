import Foundation

enum AnnouncementStatus: String {
    case composing
    case scheduled
    case queueing
    case queued
    case sending
    case sent
    case aborted

    var rank: Int {
        let order: [AnnouncementStatus] = [.composing, .queueing, .queued, .sending, .scheduled, .sent, .aborted]
        return order.firstIndex(of: self) ?? 0
    }
}
