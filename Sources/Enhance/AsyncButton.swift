
import SwiftUI

// See: https://www.swiftbysundell.com/articles/building-an-async-swiftui-button

public struct AsyncButton<Label: View>: View {
    public var actionOptions = Set(ActionOption.allCases)
    public var role: ButtonRole? = nil
    public var errorTitle: String? = nil
    public var action: () async throws -> Void
    @ViewBuilder public var label: () -> Label

    @State public var isDisabled = false
    @State public var showProgressView = false

    @Environment(\.handleError) var handleError

    public init(
        actionOptions: Set<ActionOption> = Set(ActionOption.allCases),
        role: ButtonRole? = nil,
        errorTitle: String? = nil,
        action: @escaping () async throws -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.actionOptions = actionOptions
        self.role = role
        self.errorTitle = errorTitle
        self.action = action
        self.label = label
    }

    public var body: some View {
        Button(role: role) {
            if actionOptions.contains(.disableButton) {
                isDisabled = true
            }

            Task {
                var progressViewTask: Task<Void, Error>?

                if actionOptions.contains(.showProgressView) {
                    progressViewTask = Task {
                        try await Task.sleepThrowingOnCancellation(seconds: 0.15) // Display progress view only after 0.15 seconds
                        showProgressView = true
                    }
                }

                do {
                    try await action()
                } catch {
                    handleError(title: errorTitle, error)
                }
                progressViewTask?.cancel()

                isDisabled = false
                showProgressView = false
            }
        } label: {
            if showProgressView {
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
        .disabled(isDisabled)
    }

    public func withErrorTitle(_ title: String) -> Self {
        var it = self
        it.errorTitle = title
        return it
    }
}

public extension AsyncButton {
    enum ActionOption: CaseIterable {
        case disableButton
        case showProgressView
    }
}

public extension AsyncButton where Label == Text {
    init(_ label: LocalizedStringKey, role: ButtonRole? = nil, action: @escaping () async throws -> Void) {
        self.init(role: role, action: action) {
            Text(label)
        }
    }

    @_disfavoredOverload
    init(_ label: some StringProtocol, role: ButtonRole? = nil, action: @escaping () async throws -> Void) {
        self.init(role: role, action: action) {
            Text(label)
        }
    }
}

public extension AsyncButton where Label == Image {
    init(systemImage: String, role: ButtonRole? = nil, action: @escaping () async throws -> Void) {
        self.init(role: role, action: action) {
            Image(systemName: systemImage)
        }
    }
}

public extension AsyncButton where Label == SwiftUI.Label<Text, Image> {
    init(_ label: LocalizedStringKey, systemImage: String, role: ButtonRole? = nil, action: @escaping () async throws -> Void) {
        self.init(role: role, action: action) {
            SwiftUI.Label(label, systemImage: systemImage)
        }
    }

    @_disfavoredOverload
    init(_ label: some StringProtocol, systemImage: String, role: ButtonRole? = nil, action: @escaping () async throws -> Void) {
        self.init(role: role, action: action) {
            SwiftUI.Label(label, systemImage: systemImage)
        }
    }

    init(verbatim title: some StringProtocol, systemImage: String, role: ButtonRole? = nil, action: @escaping () async throws -> Void) {
        self.init(role: role, action: action) {
            SwiftUI.Label(verbatim: title, systemImage: systemImage)
        }
    }
}

public extension AsyncButton where Label == Text {
    init(verbatim title: some StringProtocol, role: ButtonRole? = nil, action: @escaping () async throws -> Void) {
        self.init(role: role, action: action) {
            Text(title)
        }
    }
}

struct AsyncButton_Previews: PreviewProvider {
    static var previews: some View {
        AsyncButton("Cancel", action: { await Task.sleep(seconds: 1) })
            .buttonStyle(.bordered)
    }
}
