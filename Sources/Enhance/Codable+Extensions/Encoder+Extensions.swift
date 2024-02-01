
import Foundation

public extension Encoder {
    /// Encode a singular value into this encoder.
    func encodeSingleValue(_ value: some Encodable) throws {
        var container = singleValueContainer()
        try container.encode(value)
    }

    /// Encode a value for a given key, specified as a `CodingKey`.
    func encode(_ value: some Encodable, for key: some CodingKey) throws {
        var container = self.container(keyedBy: type(of: key))
        try container.encode(value, forKey: key)
    }

    /// Encode a value if not `nil` for a given key, specified as a string.
    func encodeIfPresent(_ value: (some Encodable)?, for key: some CodingKey) throws {
        if let value {
            var container = self.container(keyedBy: type(of: key))
            try container.encode(value, forKey: key)
        }
    }

    /// Encode a date for a given key (specified using a `CodingKey`), using a specific formatter.
    /// To encode a date without using a specific formatter, simply encode it like any other value.
    func encode(_ date: Date, for key: some CodingKey, using formatter: some AnyDateFormatter) throws {
        let string = formatter.string(from: date)
        try encode(string, for: key)
    }
}

extension Encoder {

    func encode(_ value: some Encodable, atPath path: [any CodingKey]) throws {
        precondition(!path.isEmpty)
        let keys = path.map(AnyCodingKey.init)
        var container = container(keyedBy: AnyCodingKey.self)
        for key in keys.dropLast() {
            container = container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
        }
        try container.encode(value, forKey: keys.last!)
    }

    func encodeIfPresent(_ value: (some Encodable)?, atPath path: [any CodingKey]) throws {
        guard let value else { return }
        try encode(value, atPath: path)
    }
}
