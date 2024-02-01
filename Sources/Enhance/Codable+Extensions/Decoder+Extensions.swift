
import Foundation

public extension Decoder {
    /// Decode a singular value from the underlying data.
    func decodeSingleValue<T: Decodable>(as type: T.Type = T.self) throws -> T {
        let container = try singleValueContainer()
        return try container.decode(type)
    }

    /// Decode a value for a given key, specified as a `CodingKey`.
    func decode<T: Decodable>(_ key: some CodingKey, as type: T.Type = T.self) throws -> T {
        let container = try self.container(keyedBy: Swift.type(of: key))
        return try container.decode(type, forKey: key)
    }

    /// Decode an optional value for a given key, specified as a `CodingKey`.
    /// - Throws: If specified key exists and is not-null and decode fails.
    func decodeIfPresent<T: Decodable>(_ key: some CodingKey, as type: T.Type = T.self) throws -> T? {
        let container = try self.container(keyedBy: Swift.type(of: key))
        return try container.decodeIfPresent(type, forKey: key)
    }
}

// MARK: - Decoding nested paths

public extension Decoder {

    func decode<T: Decodable>(atPath path: [any CodingKey], as type: T.Type = T.self) throws -> T {
        precondition(!path.isEmpty)
        let keys = path.map(AnyCodingKey.init)
        var container = try container(keyedBy: AnyCodingKey.self)
        for key in keys.dropLast() {
            container = try container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: key)
        }
        return try container.decode(type, forKey: keys.last!)
    }

    func decodeIfPresent<T: Decodable>(atPath path: [any CodingKey], as type: T.Type = T.self) throws -> T? {
        precondition(!path.isEmpty)
        do {
            return try decode(atPath: path, as: type)
        } catch {
            return try throwIfNotEmpty(error: error)
        }
    }
}

// MARK: - Specialized Decoders

public extension Decoder {

    func decode(using formatter: some AnyDateFormatter) throws -> Date {
        let container = try singleValueContainer()
        let rawString = try container.decode(String.self)
        guard let date = formatter.date(from: rawString) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to parse date string")
        }
        return date
    }

    /// Decode a date from a string for a given key (specified as a `CodingKey`), using a specific
    /// formatter.
    func decode(_ key: some CodingKey, using formatter: some AnyDateFormatter) throws -> Date {
        let container = try self.container(keyedBy: type(of: key))
        let rawString = try container.decode(String.self, forKey: key)

        guard let date = formatter.date(from: rawString) else {
            throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Unable to parse date string")
        }

        return date
    }

    /// Decode an optional date from a string for a given key (specified as a `CodingKey`), using
    /// a specific formatter.
    /// - Throws: If specified key exists and is not-null and decode fails.
    func decodeIfPresent(_ key: some CodingKey, using formatter: some AnyDateFormatter) throws -> Date? {
        do {
            return try decode(key, using: formatter)
        } catch {
            return try throwIfNotEmpty(error: error)
        }
    }

    /// Decode a date from a string allowing multiple formats to succeed. See the global variable
    /// `dateParsersToTryForDecoding` for formats, or pass your own format string in `tryFirst`
    /// to run a custom format first, falling back to the global should it fail.
    func decode(_ key: some CodingKey, allowFallbackFormats: Bool, tryFirst format: String? = nil) throws -> Date {
        guard allowFallbackFormats else { return try decode(key) }

        let container = try self.container(keyedBy: type(of: key))
        // TODO: Handle numeric epochs
        let rawString: String
        do {
            rawString = try container.decode(String.self, forKey: key)
        } catch {
            let epochOffset = try container.decode(Double.self, forKey: key)
            return Date(timeIntervalSince1970: epochOffset)
        }

        var dateFormatsToTry = dateFormattersToTryForDecoding
        if let format {
            let formatter = DateFormatter(format: format)
            dateFormatsToTry.insert(formatter, at: 0)
        }

        let date = dateFormatsToTry
            .compactMap { $0.date(from: rawString) }
            .lazy
            .first

        guard let date else {
            throw DecodingError.dataCorruptedError(
                forKey: key,
                in: container,
                debugDescription: "Unable to parse date string: \(rawString), tried \(dateFormatsToTry.count) formats unsuccessfully"
            )
        }

        return date
    }

    /// Decode an optional date from a string allowing multiple formats to succeed. See the global
    ///  variable `dateParsersToTryForDecoding` for formats, or pass your own format string in
    /// `tryFirst` to run a custom format first, falling back to the global should it fail.
    /// - Throws: If specified key exists and is not-null and decode fails.
    func decodeIfPresent(_ key: some CodingKey, allowFallbackFormats: Bool, tryFirst format: String? = nil) throws -> Date? {
        do {
            return try decode(key, allowFallbackFormats: allowFallbackFormats, tryFirst: format)
        } catch {
            return try throwIfNotEmpty(error: error)
        }
    }

    // MARK: - Specialized Number Parsers

    func decode(_ key: some CodingKey, parseStrings: Bool, using formatter: NumberFormatter = .server) throws -> Double {
        let container = try self.container(keyedBy: type(of: key))

        formatter.isLenient = true

        let rawString = try? container.decode(String.self, forKey: key)
        if let rawString {
            guard let number = formatter.number(from: rawString) else {
                throw DecodingError.dataCorruptedError(forKey: key, in: container, debugDescription: "Unable to parse number")
            }
            return number.doubleValue
        }

        return try container.decode(Double.self, forKey: key)
    }

    func decodeIfPresent(_ key: some CodingKey, parseStrings: Bool, using formatter: NumberFormatter = .server) throws -> Double? {
        do {
            return try decode(key, parseStrings: parseStrings, using: formatter)
        } catch {
            return try throwIfNotEmpty(error: error)
        }
    }
}

/// Protocol acting as a common API for all types of date formatters,
/// such as `DateFormatter` and `ISO8601DateFormatter`.
public protocol AnyDateFormatter {
    /// Format a string into a date
    func date(from string: String) -> Date?
    /// Format a date into a string
    func string(from date: Date) -> String
}

extension ISO8601DateFormatter: AnyDateFormatter {}
extension DateFormatter: AnyDateFormatter {}

public extension AnyDateFormatter where Self == ISO8601DateFormatter {
    static var iso8601: ISO8601DateFormatter { ISO8601DateFormatter() }
    static func iso8601(options: ISO8601DateFormatter.Options) -> ISO8601DateFormatter {
        ISO8601DateFormatter(withOptions: options)
    }
}

public extension JSONDecoder.DateDecodingStrategy {
    static func iso8601(options: ISO8601DateFormatter.Options) -> Self {
        .custom { decoder in
            try decoder.decode(using: .iso8601(options: options))
        }
    }
}

public var dateFormattersToTryForDecoding: [AnyDateFormatter] = [
    ISO8601DateFormatter(),
    ISO8601DateFormatter(withOptions: .withInternetDateTime),
    ISO8601DateFormatter(withOptions: .withFractionalSeconds),
    ISO8601DateFormatter(withOptions: .withTimeZone),
    DateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"),
    DateFormatter(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ"),
    DateFormatter(format: "yyyy-MM-dd"),
    DateFormatter(format: "yyyy-MM-dd'T'HH:mm:ssZ"),
    DateFormatter(format: "yyyy-MM-dd HH:mm:ss Z"),
]

public extension ISO8601DateFormatter {

    convenience init(withOptions options: ISO8601DateFormatter.Options) {
        self.init()
        self.formatOptions.insert(options)
    }
}

public extension DateFormatter {

    convenience init(format: String, isLenient: Bool = true) {
        self.init()
        self.dateFormat = format
        self.locale = Locale(identifier: "en_US_POSIX")
    }
}

public extension NumberFormatter {
    static var server: NumberFormatter = {
        let nf = NumberFormatter()
        nf.locale = Locale(identifier: "en_US_POSIX")
        nf.isLenient = true
        return nf
    }()
}

private func throwIfNotEmpty<T>(error: Error) throws -> T? {
    switch (error as? DecodingError) {
    case .valueNotFound?, .keyNotFound?: return nil
    default: throw error
    }
}
