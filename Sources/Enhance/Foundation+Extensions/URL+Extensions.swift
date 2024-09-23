
import Foundation

extension URL: Swift.ExpressibleByStringLiteral {

    public init(stringLiteral value: StaticString) {
        self.init(string: value.description)!
    }
}
