
import SwiftUI

public struct JumpChangeEffect: ChangeEffect {
    public var height: CGFloat

    public init(height: CGFloat) {
        self.height = height
    }

    public func modifier(count: Int) -> some ViewModifier {
        Modifier(height: height, animatableData: CGFloat(count))
    }

    struct Modifier: GeometryEffect {
        var height: CGFloat
        var animatableData: CGFloat

        func effectValue(size: CGSize) -> ProjectionTransform {
            let yOffs = -height * abs(sin(animatableData * .pi))
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
    static var previews: some View {
        ChangeEffectPreview(effect: .scale)
    }
}
