import Foundation

enum UnsupportedQuiz {
    // Show step web version
    enum UnsupportedQuizPresentation {
        struct Request { }

        struct Response {
            let stepURLPath: String
        }

        struct ViewModel {
            let stepURLPath: String
        }
    }
}
