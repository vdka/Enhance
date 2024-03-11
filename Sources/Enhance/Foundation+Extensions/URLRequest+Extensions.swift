
import Combine
import Foundation

public extension URLRequest {

    init(url: URL, method: String, bodyData: Data? = nil) {
        self.init(url: url)
        self.httpMethod = method
        self.httpBody = bodyData
    }

    init<Value: Encodable, Encoder: TopLevelEncoder>(
        url: URL,
        method: String,
        encoder: Encoder = JSONEncoder().with(dateEncodingStrategy: .iso8601),
        body: Value
    )
        where Encoder.Output == Data
    {
        self.init(url: url)
        self.httpMethod = method
        do {
            self.httpBody = try encoder.encode(body)
        } catch {
            log.error("Failed to encode body")
        }
    }
}
