import Foundation

struct CourseListGridSize {
    static let defaultRowsCount = 2
    static let defaultColumnsCount = 1

    static var `default`: CourseListGridSize { .init(rows: Self.defaultRowsCount) }

    var rows: Int
    var columns: Int

    let isAutoColumns: Bool

    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        self.isAutoColumns = false
    }

    init(rows: Int) {
        self.rows = rows
        self.columns = CourseListGridSize.defaultColumnsCount
        self.isAutoColumns = true
    }
}
