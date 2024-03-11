
import Foundation

public extension JSONEncoder {

    func with(dateEncodingStrategy: DateEncodingStrategy) -> JSONEncoder {
        self.dateEncodingStrategy = dateEncodingStrategy
        return self
    }
}
