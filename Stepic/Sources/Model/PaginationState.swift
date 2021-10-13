import Foundation

struct PaginationState {
    let page: Int
    let hasNext: Bool

    init(page: Int = 1, hasNext: Bool = false) {
        self.page = page
        self.hasNext = hasNext
    }
}
