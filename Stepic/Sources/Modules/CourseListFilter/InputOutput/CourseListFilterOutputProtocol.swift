import Foundation

protocol CourseListFilterOutputProtocol: AnyObject {
    func handleCourseListFilterDidFinishWithFilters(_ filters: [CourseListFilter.Filter])
}
