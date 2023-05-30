
import SwiftUI

public struct ScaleChangeEffect: ChangeEffect {
    public var amount: CGFloat

    public init(amount: CGFloat) {
        self.amount = amount
    }

    public func modifier(count: Int) -> some ViewModifier {
        Modifier(amount: amount, animatableData: CGFloat(count)).defaultAnimation(.easeInOut)
    }

    struct Modifier: GeometryEffect {
        var amount: CGFloat
        var animatableData: CGFloat

        func effectValue(size: CGSize) -> ProjectionTransform {
            let scale = abs(sin(animatableData * .pi)) * (amount - 1) + 1
            let transform = CGAffineTransform.identity
                .translatedBy(x: size.width / 2, y: size.height / 2)
                .scaledBy(x: scale, y: scale)
                .translatedBy(x: -size.width / 2, y: -size.height / 2)
            return ProjectionTransform(transform)
        }
    }
}

public extension ChangeEffect where Self == ScaleChangeEffect {
    static var scale: Self { Self(amount: 1.15) }

    static func scale(amount: CGFloat) -> Self {
        Self(amount: amount)
    }
}

struct Scale_Previews: PreviewProvider {
    static var previews: some View {
        ChangeEffectPreview(effect: .scale)
    }
}
