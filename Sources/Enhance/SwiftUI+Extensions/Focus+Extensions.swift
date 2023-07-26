
import SwiftUI

public extension View {

    @ViewBuilder
    @_disfavoredOverload
    @available(iOS, introduced: 16)
    func prefersDefaultFocus<V>(
        _ binding: FocusState<V>.Binding,
        _ value: V,
        priority: DefaultFocusEvaluationPriority = .automatic
    ) -> some View where V : Hashable {
#if compiler(>=5.9)
        if #available(iOS 17, macOS 13, tvOS 16, watchOS 9, *) {
            self.defaultFocus(binding, value, priority: priority)
        } else {
            self.onAppear(perform: { binding.wrappedValue = value })
        }
#else
        self.onAppear(perform: { binding.wrappedValue = value })
#endif
    }
}
