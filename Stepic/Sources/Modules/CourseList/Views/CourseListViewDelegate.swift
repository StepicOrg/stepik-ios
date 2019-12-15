import Foundation

protocol CourseListViewDelegate: AnyObject {
    func courseListViewDidPaginationRequesting(_ courseListView: CourseListView)
}
