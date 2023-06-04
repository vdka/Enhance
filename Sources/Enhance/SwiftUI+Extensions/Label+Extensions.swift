
import SwiftUI

public extension Label where Title == Text, Icon == Image {
    init(verbatim title: some StringProtocol, systemImage: String) {
        self.init(title, systemImage: systemImage)
    }
}
