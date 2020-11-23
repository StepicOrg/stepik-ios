import Foundation

enum CatalogBlocks {
    // MARK: Use Cases

    /// Show catalog blocks
    enum CatalogBlocksLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<[CatalogBlock]>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case result(data: [CatalogBlock])
    }
}
