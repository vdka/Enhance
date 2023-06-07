
import SwiftUI

public struct ShakeChangeEffect: ChangeEffect {
    public var delay: TimeInterval = 0
    public var cooldown: TimeInterval = 0
    public var defaultAnimation: Animation? = .easeInOut(duration: 1.5)

    public var amount: CGFloat = 5
    public var oscillations: Int = 3

    public init(amount: CGFloat = 5, oscillations: Int = 3) {
        self.amount = amount
        self.oscillations = oscillations
    }

    public func modifier(count: Int) -> some ViewModifier {
        Modifier(amount: amount, oscillations: oscillations, animatableData: CGFloat(count))
    }

    struct Modifier: GeometryEffect {
        var amount: CGFloat
        var oscillations: Int
        var animatableData: CGFloat

        func effectValue(size: CGSize) -> ProjectionTransform {
            let xOffs = amount * sin(animatableData * .tau * CGFloat(oscillations))
            return ProjectionTransform(CGAffineTransform(translationX: xOffs, y: 0))
        }
    }
}

public extension ChangeEffect where Self == ShakeChangeEffect {
    static var shake: Self { ShakeChangeEffect() }

    static func shake(amount: CGFloat, oscillations: Int = 3) -> Self {
        Self(amount: amount, oscillations: oscillations)
    }
}

struct Shake_Previews: PreviewProvider {
    static var previews: some View {
        ChangeEffectPreview { $date in
            Button(action: { date = .now }) {
                Label("Checkout", systemImage: "cart")
            }
            .buttonStyle(.borderedProminent)
            .changeEffect(.shake, value: date)
        }
    }
}
