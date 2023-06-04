
import SwiftUI

public extension Toggle where Label == Text {
    init(verbatim title: some StringProtocol, isOn: Binding<Bool>) {
        self.init(title, isOn: isOn)
    }
}
