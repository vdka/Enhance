
import SwiftUI

public struct PushDownConditionalEffect: ConditionalEffect {

    public var delay: TimeInterval = 0
    public var defaultAnimation: Animation? = .bouncy

    public init() { }

    public func modifier(isActive: Bool) -> some ViewModifier {
        Modifier(animatableData: isActive ? 1 : 0)
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
        @Environment(\.isEnabled) var isEnabled

        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 64)
                .background(.tint, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                .opacity(configuration.isPressed ? 0.75 : 1)
                .conditionalEffect(.pushDown, condition: configuration.isPressed)
                .changeEffect(.feedbackHapticSelection, value: configuration.isPressed)
                .changeEffect(.shimmer, value: isEnabled, isEnabled: isEnabled)
                .animation(.easeInOut, value: isEnabled)
        }
    }

    static var previews: some View {
        ChangeEffectPreview(fireFrequency: 5) { $date in
            let enable = Int(date.timeIntervalSinceReferenceDate) % 2 == 0
            Button(action: { }) {
                Label("Checkout", systemImage: "cart")
            }
            .buttonStyle(PushDownButtonStyle())
            .disabled(!enable)
        }
    }
}
