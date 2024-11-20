
import SwiftUI

public struct ScaleChangeEffect: ChangeEffect {
    public var delay: TimeInterval = 0
    public var cooldown: TimeInterval = 0
    public var defaultAnimation: Animation? = .easeInOut

    public var amount: CGFloat = 1.15

    public init(amount: CGFloat = 1.15) {
        self.amount = amount
    }

    public func modifier(count: Int) -> some ViewModifier {
        Modifier(amount: amount, animatableData: CGFloat(count))
    }

    struct Modifier: GeometryEffect {
        var amount: CGFloat
        var animatableData: CGFloat
        var factor: CGFloat { sin(animatableData.truncatingRemainder(dividingBy: 1) * .pi) }

        func effectValue(size: CGSize) -> ProjectionTransform {
            let scale = 1 + factor * (amount - 1)
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
        ChangeEffectPreview { $date in
            Button(action: { date = .now }) {
                Label("Checkout", systemImage: "cart")
            }
            .buttonStyle(.borderedProminent)
            .changeEffect(.scale, value: date)
        }
    }
}
