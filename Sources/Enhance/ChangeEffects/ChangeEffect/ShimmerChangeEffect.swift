
import SwiftUI

public struct ShimmerChangeEffect: ChangeEffect {
    public var delay: TimeInterval = 0
    public var cooldown: TimeInterval = 3
    public var defaultAnimation: Animation? = .easeInOut(duration: 2.5)

    public func modifier(count: Int) -> some ViewModifier {
        AnimatedMask(animatableData: CGFloat(count))
    }

    struct AnimatedMask: ViewModifier, Animatable {
        var animatableData: CGFloat
        var phase: CGFloat { animatableData.truncatingRemainder(dividingBy: 1) }

        func body(content: Content) -> some View {
            content
                .overlay { GradientMask(phase: phase).opacity(0.4) }
                .mask { content }
        }
    }

    struct GradientMask: View {
        let phase: CGFloat
        let centerColor = Color.black

        @Environment(\.layoutDirection) var layoutDirection

        var body: some View {
            let isRightToLeft = layoutDirection == .rightToLeft

            GeometryReader { geometry in
                let gradient = Gradient(stops: [
                    .init(color: .clear, location: phase + 0.0),
                    .init(color: .white, location: phase + 0.1),
                    .init(color: .clear, location: phase + 0.2),
                ])
                LinearGradient(
                    gradient: gradient,
                    startPoint: isRightToLeft ? .bottomTrailing : .topLeading,
                    endPoint: isRightToLeft ? .topLeading : .bottomTrailing
                )
                .frame(width: geometry.size.width * 2) // Double parents width
                .offset(x: -geometry.size.width / 2) // Center on parent
            }
        }
    }
}

public extension ChangeEffect where Self == ShimmerChangeEffect {
    static var shimmer: Self { Self() }
}

struct Shimmer_Previews: PreviewProvider {
    static var previews: some View {
        ChangeEffectPreview { $date in
            Button(action: { date = .now }) {
                Label("Checkout", systemImage: "cart")
            }
            .buttonStyle(.borderedProminent)
            .changeEffect(.shimmer, value: date)
        }
    }
}
