
extension String: CodingKey {
    public var stringValue: String { self }
    public var intValue: Int? { nil }

    public init?(intValue: Int) { nil }
    public init?(stringValue: String) { self = stringValue }
}
