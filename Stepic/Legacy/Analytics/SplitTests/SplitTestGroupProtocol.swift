import Foundation

protocol SplitTestGroupProtocol: RawRepresentable where RawValue == String {
    static var groups: [Self] { get }
}
