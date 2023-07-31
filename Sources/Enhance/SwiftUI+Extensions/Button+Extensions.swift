
import SwiftUI

/// - Note: Introduced to SwiftUI in Xcode15B5
/// - SeeAlso: https://developer.apple.com/documentation/swiftui/button/init(_:systemimage:action:)-6346x
#if swift(<5.9)
public extension Button where Label == SwiftUI.Label<Text, Image> {
    init(_ label: LocalizedStringKey, systemImage: String, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.init(role: role, action: action) {
            SwiftUI.Label(label, systemImage: systemImage)
        }
    }

    @_disfavoredOverload
    init(_ label: some StringProtocol, systemImage: String, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.init(role: role, action: action) {
            SwiftUI.Label(label, systemImage: systemImage)
        }
    }
}
#endif

public extension Button where Label == Text {

    init(verbatim title: some StringProtocol, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.init(role: role, action: action) {
            Text(title)
        }
    }
}
