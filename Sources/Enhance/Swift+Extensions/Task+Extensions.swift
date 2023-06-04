
public extension Task where Success == Never, Failure == Never {

    /// - Note: This calls to `Task.sleep(nanoseconds:)` which throws on Cancellation, but we ignore that error.
    ///   If the cancellation error is important in your calling code use `Thread.sleepThrowingOnCancellation(seconds:)`
    static func sleep(seconds: Double) async {
        let duration = UInt64(seconds * 1_000_000_000)
        try? await Task.sleep(nanoseconds: duration)
    }

    static func sleepThrowingOnCancellation(seconds: Double) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}
