import Foundation
import SwiftDate

extension Date {
    static var europeMoscowRegion: Region {
        Region(
            calendar: Calendar.autoupdatingCurrent,
            zone: Zones.europeMoscow.toTimezone(),
            locale: Locale.autoupdatingCurrent
        )
    }

    var inEuropeMoscow: DateInRegion {
        self.in(region: Self.europeMoscowRegion)
    }
}
