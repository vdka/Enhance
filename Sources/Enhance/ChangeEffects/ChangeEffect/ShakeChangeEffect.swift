
import SwiftUI

public struct ShakeChangeEffect: ChangeEffect {
    public var amount: CGFloat = 5
    public var oscillations: Int = 2

    public init(amount: CGFloat = 5, oscillations: Int = 2) {
        self.amount = amount
        self.oscillations = oscillations
    }

    public func modifier(count: Int) -> some ViewModifier {
        Modifier(amount: amount, oscillations: oscillations, animatableData: CGFloat(count))
            .defaultAnimation(.easeInOutExponential)
    }

    struct Modifier: GeometryEffect {
        var amount: CGFloat
        var oscillations: Int
        var animatableData: CGFloat

        func effectValue(size: CGSize) -> ProjectionTransform {
            let xOffs = amount * sin(animatableData * .pi * 2 * CGFloat(oscillations))
            return ProjectionTransform(CGAffineTransform(translationX: xOffs, y: 0))
        }
    }
}

public extension ChangeEffect where Self == ShakeChangeEffect {
    static var shake: Self { ShakeChangeEffect() }

    static func shake(amount: CGFloat, oscillations: Int = 2) -> Self {
        Self(amount: amount, oscillations: oscillations)
    }
}

struct Shake_Previews: PreviewProvider {
    static var previews: some View {
        ChangeEffectPreview(effect: .shake)
    }
}
