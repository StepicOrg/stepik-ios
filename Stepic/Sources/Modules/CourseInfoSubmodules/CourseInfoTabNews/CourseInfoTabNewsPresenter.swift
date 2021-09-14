import UIKit

protocol CourseInfoTabNewsPresenterProtocol {
    func presentCourseNews(response: CourseInfoTabNews.NewsLoad.Response)
}

final class CourseInfoTabNewsPresenter: CourseInfoTabNewsPresenterProtocol {
    weak var viewController: CourseInfoTabNewsViewControllerProtocol?

    func presentCourseNews(response: CourseInfoTabNews.NewsLoad.Response) {}
}
