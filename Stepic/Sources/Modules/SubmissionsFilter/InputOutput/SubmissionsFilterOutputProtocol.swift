import Foundation

protocol SubmissionsFilterOutputProtocol: AnyObject {
    func handleSubmissionsFilterDidFinishWithFilters(_ filters: [SubmissionsFilter.Filter])
}
