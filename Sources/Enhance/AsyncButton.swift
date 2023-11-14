
import SwiftUI

// See: https://www.swiftbysundell.com/articles/building-an-async-swiftui-button

public struct AsyncButton<Label: View>: View {
    public var options: AsyncButtonOption = AsyncButtonOption.all
    public var role: ButtonRole? = nil
    public var errorTitle: String?
    public var action: () async throws -> Void
    @ViewBuilder public var label: () -> Label

    @State public var isDisabled = false
    @State public var showProgressView = false
    @State public var error: Error?

    @Environment(\.handleError) var handleError

    public init(
        options: AsyncButtonOption = .all,
        role: ButtonRole? = nil,
        errorTitle: String? = nil,
        action: @escaping () async throws -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.options = options
        self.role = role
        self.errorTitle = errorTitle
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button(role: role) {
            if options.contains(.disableButton) {
                isDisabled = true
            }

            Task {
                var progressViewTask: Task<Void, Error>?

                if options.contains(.showProgressView) {
                    progressViewTask = Task {
                        try await Task.sleepThrowingOnCancellation(seconds: 0.15) // Display progress view only after 0.15 seconds
                        showProgressView = true
                    }
                }

                do {
                    try await action()
                } catch {
                    self.error = error
                    handleError(title: errorTitle, error)
                    await Task.sleep(seconds: 0.5)
                    self.error = nil
                }
                progressViewTask?.cancel()

                isDisabled = false
                showProgressView = false
            }
        } label: {
            if error != nil {
                Image(systemName: "exclamationmark.circle.fill").foregroundStyle(.red)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else if showProgressView {
                ZStack {
                    ProgressView()
                    label().opacity(0)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                label().transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOutBack, value: showProgressView)
        .animation(.easeInOutBack, value: error != nil)
        .disabled(isDisabled || error != nil)
    }

    func withErrorTitle(_ title: String) -> Self {
        var copy = self
        copy.errorTitle = title
        return copy
    }
}

public struct AsyncButtonOption: OptionSet {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let disableButton     = AsyncButtonOption(rawValue: 0b0001)
    public static let showProgressView  = AsyncButtonOption(rawValue: 0b0010)
    public static let titleAsErrorTitle = AsyncButtonOption(rawValue: 0b0100)

    public static let all = AsyncButtonOption(rawValue: ~0)
}

public extension AsyncButton where Label == Text {
    init(
        _ title: LocalizedStringKey,
        role: ButtonRole? = nil,
        options: AsyncButtonOption = .all,
        action: @escaping () async throws -> Void
    ) {
        self.init(options: options, role: role, action: action) {
            Text(title)
        }
        if let key = title.key, key.contains("%") == false {
            self.errorTitle = String(localized: "\(key) Failed")
        }
    }

    @_disfavoredOverload
    init(
        _ title: some StringProtocol,
        role: ButtonRole? = nil,
        options: AsyncButtonOption = .all,
        action: @escaping () async throws -> Void
    ) {
        self.init(options: options, role: role, action: action) {
            Text(title)
        }
        self.errorTitle = String(localized: "\(String(title)) Failed")
    }
}

public extension AsyncButton where Label == Image {
    init(
        systemImage: String,
        role: ButtonRole? = nil,
        options: AsyncButtonOption = .all,
        action: @escaping () async throws -> Void
    ) {
        self.init(options: options, role: role, action: action) {
            Image(systemName: systemImage)
        }
    }
}

public extension AsyncButton where Label == SwiftUI.Label<Text, Image> {
    init(
        _ title: LocalizedStringKey,
        systemImage: String,
        role: ButtonRole? = nil,
        options: AsyncButtonOption = .all,
        action: @escaping () async throws -> Void
    ) {
        self.init(options: options, role: role, action: action) {
            SwiftUI.Label(title, systemImage: systemImage)
        }
        if let key = title.key, key.contains("%") == false {
            self.errorTitle = String(localized: "\(key) Failed")
        }
    }

    @_disfavoredOverload
    init(
        _ title: some StringProtocol,
        systemImage: String,
        role: ButtonRole? = nil,
        options: AsyncButtonOption = .all,
        action: @escaping () async throws -> Void
    ) {
        self.init(options: options, role: role, action: action) {
            SwiftUI.Label(title, systemImage: systemImage)
        }
        self.errorTitle = String(localized: "\(String(title)) Failed")
    }

    init(
        verbatim title: some StringProtocol,
        systemImage: String,
        role: ButtonRole? = nil,
        options: AsyncButtonOption = .all,
        action: @escaping () async throws -> Void
    ) {
        self.init(options: options, role: role, action: action) {
            SwiftUI.Label(verbatim: title, systemImage: systemImage)
        }
        self.errorTitle = String(localized: "\(String(title)) Failed")
    }
}

public extension AsyncButton where Label == Text {
    init(
        verbatim title: some StringProtocol,
        role: ButtonRole? = nil,
        options: AsyncButtonOption = .all,
        action: @escaping () async throws -> Void
    ) {
        self.init(options: options, role: role, action: action) {
            Text(title)
        }
        self.errorTitle = String(localized: "\(String(title)) Failed")
    }
}

struct AsyncButton_Previews: PreviewProvider {
    static var previews: some View {
        AsyncButton("Cancel", action: {
            await Task.sleep(seconds: 1)
            throw Error.error
        })
        .buttonStyle(.bordered)
        .handleError(using: { print($0 ?? "nil", $1) })
    }

    private enum Error: Swift.Error {
        case error
    }
}

private extension LocalizedStringKey {
    var key: String? {
        Mirror(reflecting: self)
            .children
            .first(where: { $0.label?.hasSuffix("key") == true })?
            .value as? String
    }
}
