import Foundation

// Conforms to WriteCommentOutputProtocol to be able to discussions module with embedded write comment module.
// See NewStepViewController's displayDiscussions(viewModel:) usages.
protocol DiscussionsInputProtocol: WriteCommentOutputProtocol { }
