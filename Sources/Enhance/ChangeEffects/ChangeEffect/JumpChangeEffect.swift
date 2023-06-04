
import SwiftUI

public struct JumpChangeEffect: ChangeEffect {
    public var delay: TimeInterval = 0
    public var cooldown: TimeInterval = 3
    public var defaultAnimation: Animation? = .easeInBack

    public var height: CGFloat

    public init(height: CGFloat) {
        self.height = height
    }

    public func modifier(count: Int) -> some ViewModifier {
        Modifier(maxHeight: height, animatableData: CGFloat(count))
    }

    struct Modifier: GeometryEffect {
        var maxHeight: CGFloat
        var animatableData: CGFloat
        var height: CGFloat { animatableData.truncatingRemainder(dividingBy: 1) }

        func effectValue(size: CGSize) -> ProjectionTransform {
            let yOffs = -maxHeight * sin(height * .pi)
            return ProjectionTransform(CGAffineTransform(translationX: 0, y: yOffs))
        }
    }
}

public extension ChangeEffect where Self == JumpChangeEffect {
    static func jump(height: CGFloat) -> Self {
        Self(height: height)
    }
}

struct Jump_Previews: PreviewProvider {
    static var effect: JumpChangeEffect {
        var effect = JumpChangeEffect(height: 15)
        effect.delay = 0.5
        return effect
    }
    static var previews: some View {
        ChangeEffectPreview { $date in
            Button(action: { date = .now }) {
                Label("Checkout", systemImage: "cart")
            }
            .buttonStyle(.borderedProminent)
            .changeEffect(effect, value: date)
            .changeEffect(.scale, value: date)
        }
    }
}
