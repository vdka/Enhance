
import SwiftUI

/// - Note: Introduced to SwiftUI in Xcode15b5
/// - SeeAlso: https://developer.apple.com/documentation/swiftui/toggle/init(_:systemimage:ison:)-4wc5w
#if swift(<5.9)
public extension Toggle where Label == SwiftUI.Label<Text, Image> {
    init(_ label: LocalizedStringKey, systemImage: String, isOn: Binding<Bool>) {
        self.init(isOn: isOn) {
            SwiftUI.Label(label, systemImage: systemImage)
        }
    }

    @_disfavoredOverload
    init(_ label: some StringProtocol, systemImage: String, isOn: Binding<Bool>) {
        self.init(isOn: isOn) {
            SwiftUI.Label(label, systemImage: systemImage)
        }
    }
}
#endif

public extension Toggle where Label == Text {
    init(verbatim title: some StringProtocol, isOn: Binding<Bool>) {
        self.init(title, isOn: isOn)
    }
}
