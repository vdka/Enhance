
import SwiftUI

extension View {
    /// - SeeAlso: https://fivestars.blog/articles/reverse-masks-how-to
    @inlinable
    func inverseMask(alignment: Alignment = .center, @ViewBuilder _ mask: () -> some View) -> some View {
        self.mask {
            Rectangle()
                .overlay(alignment: alignment) {
                    mask().blendMode(.destinationOut)
                }
        }
    }
}
