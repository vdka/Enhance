
import SwiftUI
import OSLog

public struct HandleErrorAction {
    let action: (String?, Error) -> Void

    public init(action: @escaping (String?, Error) -> Void) {
        self.action = action
    }

    public func callAsFunction(title: String? = nil, _ error: Error) {
        action(title, error)
    }
}

public extension View {

    func handleError(using action: @escaping (String?, Error) -> Void) -> some View {
        let instance = HandleErrorAction(action: action)
        return self.environment(\.handleError, instance)
    }
}

public struct HandleErrorKey: EnvironmentKey {
    public static let defaultValue = HandleErrorAction { title, error in
        log.error("No handler configured to handle title: \(title ?? "nil"), error: \(error)")
    }
}

public extension EnvironmentValues {
    var handleError: HandleErrorAction {
        get { self[HandleErrorKey.self] }
        set { self[HandleErrorKey.self] = newValue }
    }
}
