
import SwiftUI

/*
 * See https://www.swiftbysundell.com/articles/building-an-async-swiftui-button
 * See https://www.fivestars.blog/articles/optional-binding/
 */

public struct AsyncButton<Label: View>: View {
    public var options: AsyncButtonOption = AsyncButtonOption.all
    public var role: ButtonRole? = nil
    public var errorTitle: String?

    @State var isLoadingStored: Bool = false
    var isLoading: Binding<Bool>?

    public var action: () async throws -> Void
    @ViewBuilder public var label: () -> Label

    @State public var error: Error?

    public init(
        options: AsyncButtonOption = AsyncButtonOption.all,
        role: ButtonRole? = nil,
        errorTitle: String? = nil,
        isLoading: Binding<Bool>? = nil,
        action: @escaping () async throws -> Void,
        label: @escaping () -> Label
    ) {
        self.options = options
        self.role = role
        self.errorTitle = errorTitle
        self.isLoading = isLoading
        self.action = action
        self.label = label
    }

    public var body: some View {
        _AsyncButton(
            options: options,
            role: role,
            isLoading: isLoading ?? $isLoadingStored,
            errorTitle: errorTitle,
            action: action,
            label: label
        )
    }

    func withErrorTitle(_ title: String) -> Self {
        var copy = self
        copy.errorTitle = title
        return copy
    }

    struct _AsyncButton: View {
        var options: AsyncButtonOption = AsyncButtonOption.all
        var role: ButtonRole? = nil
        @Binding var isLoading: Bool
        var errorTitle: String?
        var action: () async throws -> Void
        @ViewBuilder var label: () -> Label

        @State var error: Error?

        var showProgressView: Bool { isLoading && options.contains(.showProgressView) }
        var isDisabled: Bool { isLoading && options.contains(.disableButton) }

        @Environment(\.handleError) var handleError

        var body: some View {
            Button(role: role) {
                isLoading = true

                Task {
                    defer { isLoading = false }
                    var progressViewTask: Task<Void, Error>?

                    if options.contains(.showProgressView) {
                        progressViewTask = Task {
                            try await Task.sleepThrowingOnCancellation(seconds: 0.15) // Display progress view only after 0.15 seconds
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
        isLoading: Binding<Bool>? = nil,
        options: AsyncButtonOption = .all,
        action: @escaping () async throws -> Void
    ) {
        self.init(options: options, role: role, isLoading: isLoading, action: action) {
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
        isLoading: Binding<Bool>? = nil,
        options: AsyncButtonOption = .all,
        action: @escaping () async throws -> Void
    ) {
        self.init(options: options, role: role, isLoading: isLoading, action: action) {
            Text(title)
        }
        self.errorTitle = String(localized: "\(String(title)) Failed")
    }
}

public extension AsyncButton where Label == Image {
    init(
        systemImage: String,
        role: ButtonRole? = nil,
        isLoading: Binding<Bool>? = nil,
        options: AsyncButtonOption = .all,
        action: @escaping () async throws -> Void
    ) {
        self.init(options: options, role: role, isLoading: isLoading, action: action) {
            Image(systemName: systemImage)
        }
    }
}

public extension AsyncButton where Label == SwiftUI.Label<Text, Image> {
    init(
        _ title: LocalizedStringKey,
        systemImage: String,
        role: ButtonRole? = nil,
        isLoading: Binding<Bool>? = nil,
        options: AsyncButtonOption = .all,
        action: @escaping () async throws -> Void
    ) {
        self.init(options: options, role: role, isLoading: isLoading, action: action) {
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
        isLoading: Binding<Bool>? = nil,
        options: AsyncButtonOption = .all,
        action: @escaping () async throws -> Void
    ) {
        self.init(options: options, role: role, isLoading: isLoading, action: action) {
            SwiftUI.Label(title, systemImage: systemImage)
        }
        self.errorTitle = String(localized: "\(String(title)) Failed")
    }

    init(
        verbatim title: some StringProtocol,
        systemImage: String,
        role: ButtonRole? = nil,
        isLoading: Binding<Bool>? = nil,
        options: AsyncButtonOption = .all,
        action: @escaping () async throws -> Void
    ) {
        self.init(options: options, role: role, isLoading: isLoading, action: action) {
            SwiftUI.Label(verbatim: title, systemImage: systemImage)
        }
        self.errorTitle = String(localized: "\(String(title)) Failed")
    }
}

public extension AsyncButton where Label == Text {
    init(
        verbatim title: some StringProtocol,
        role: ButtonRole? = nil,
        isLoading: Binding<Bool>? = nil,
        options: AsyncButtonOption = .all,
        action: @escaping () async throws -> Void
    ) {
        self.init(options: options, role: role, isLoading: isLoading, action: action) {
            Text(title)
        }
        self.errorTitle = String(localized: "\(String(title)) Failed")
    }
}

#Preview {
    return Group {
        AsyncButton("Cancel", action: {
            await Task.sleep(seconds: 1)
            throw URLError(.badServerResponse)
        })
        .handleError(using: { print($0 ?? "nil", $1) })
        SampleIsLoadingBinding()
    }
    .buttonStyle(.bordered)
}

fileprivate struct SampleIsLoadingBinding: View {
    @State var isLoading = false

    var body: some View {
        Button("Trigger", action: action)

        AsyncButton("Async Button", isLoading: $isLoading, action: { await Task.sleep(seconds: 1) })
    }

    func action() {
        isLoading = true
        Task {
            defer { isLoading = false }
            await actionBody()
        }
    }

    func actionBody() async {
            await Task.sleep(seconds: 1)
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
