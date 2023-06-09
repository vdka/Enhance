import SwiftUI

struct OnFirstAppearViewModifier: ViewModifier {
    let action: () async -> Void

    @State var hasAppeared = false

    init(perform action: @escaping () async -> Void) {
        self.action = action
    }

    func body(content: Content) -> some View {
        content.task {
            guard !hasAppeared else { return }
            hasAppeared = true
            await action()
        }
    }
}

public extension View {
    /// Adds an action to perform before this view appears for the first time
    /// - Note: Internally this calls to the ``SwiftUI/View/task(priority:_)`` modifier and follows the semantics described there
    func onFirstAppear(perform action: @escaping () async -> Void) -> some View {
        modifier(OnFirstAppearViewModifier(perform: action))
    }
}
