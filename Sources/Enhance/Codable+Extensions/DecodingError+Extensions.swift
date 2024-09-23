
extension Swift.DecodingError: Swift.CustomStringConvertible {

    var context: Swift.DecodingError.Context {
        switch self {
        case .dataCorrupted(let context): return context
        case .keyNotFound(_, let context): return context
        case .typeMismatch(_, let context): return context
        case .valueNotFound(_, let context): return context
        @unknown default: fatalError()
        }
    }

    public var description: String {
        var str = ""
        switch self {
        case .dataCorrupted: str += "data corrupted"
        case .keyNotFound:   str += "key not found"
        case .typeMismatch:  str += "type mismatch"
        case .valueNotFound: str += "value not found"
        @unknown default: fatalError()
        }
        str += " (" + keyPath + ")"
        return str
    }

    var keyPath: String {
        var keys: [any CodingKey] = context.codingPath
        if case .keyNotFound(let codingKey, _) = self {
            keys.append(codingKey)
        }
        return keys.reduce("") { str, key in
            if let index = key.intValue {
                return "\(str)[\(index)]"
            }
            return str + "." + key.stringValue
        }
    }
}
