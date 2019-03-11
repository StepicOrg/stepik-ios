import Foundation

protocol CourseListViewDelegate: class {
    func courseListViewDidPaginationRequesting(_ courseListView: CourseListView)
}
