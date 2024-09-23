
public struct AnyCodingKey: CodingKey, Hashable, ExpressibleByStringLiteral {
    public var stringValue: String
    public var intValue: Int?

    public init(stringValue: String) {
        self.stringValue = stringValue
    }

    public init(intValue: Int) {
        self.intValue = intValue
        self.stringValue = String(intValue)
    }

    public init(_ codingKey: any CodingKey) {
        self.intValue = codingKey.intValue
        self.stringValue = codingKey.stringValue
    }

    public init(stringLiteral value: String) {
        self.stringValue = value
    }
}
