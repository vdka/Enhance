
import SwiftUI

public extension Button where Label == Text {

    init(verbatim title: some StringProtocol, role: ButtonRole? = nil, action: @escaping () -> Void) {
        self.init(role: role, action: action) {
            Text(title)
        }
    }
}
