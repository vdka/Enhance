
import SwiftUI

public struct PushDownConditionalEffect: ConditionalEffect {

    public init() { }

    public func modifier(isActive: Bool) -> some ViewModifier {
        Modifier(animatableData: isActive ? 1 : 0).defaultAnimation(.bouncy)
    }

    struct Modifier: GeometryEffect {
        var animatableData: CGFloat

        func effectValue(size: CGSize) -> ProjectionTransform {
            let pct = clamp(animatableData, minValue: 0, maxValue: 1)
            let yOffs = lerp(t: pct, 0, 1)
            let scale = lerp(t: 1 - pct, 0.95, 1)

            let transform = CGAffineTransform.identity
                .translatedBy(x: size.width / 2, y: size.height)
                .scaledBy(x: scale, y: scale)
                .translatedBy(x: -size.width / 2, y: -size.height)
                .translatedBy(x: 0, y: yOffs)
            return ProjectionTransform(transform)
        }
    }
}

public extension ConditionalEffect where Self == PushDownConditionalEffect {
    static var pushDown: Self { Self() }
}

struct PushDown_Previews: PreviewProvider {

    struct PushDownButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.body.bold())
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 64)
                .background(.tint, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .opacity(configuration.isPressed ? 0.75 : 1)
                .conditionalEffect(PushDownConditionalEffect.pushDown, condition: configuration.isPressed)
                .changeEffect(.feedbackHapticSelection, value: configuration.isPressed)
        }
    }

    static var previews: some View {
        Button("Submit", action: { }).buttonStyle(PushDownButtonStyle())
    }
}
