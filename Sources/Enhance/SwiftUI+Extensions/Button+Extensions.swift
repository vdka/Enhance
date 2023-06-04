
import SwiftUI

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

public extension Button where Label == Text {

    init(verbatim title: some StringProtocol, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.init(role: role, action: action) {
            Text(title)
        }
    }
}
