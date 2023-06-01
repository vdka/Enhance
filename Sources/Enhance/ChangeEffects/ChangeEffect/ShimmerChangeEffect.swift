
import SwiftUI

struct ShimmerChangeEffect: ChangeEffect {

    func modifier(count: Int) -> some ViewModifier {
        AnimatedMask(phase: CGFloat(count)).defaultAnimation(.easeInOut(duration: 2.5))
    }

    struct AnimatedMask: ViewModifier, Animatable {
        var phase: CGFloat
        var animatableData: CGFloat {
            get { phase }
            set { phase = newValue.truncatingRemainder(dividingBy: 1) }
        }

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

extension ChangeEffect where Self == ShimmerChangeEffect {
    static var shimmer: Self { Self() }
}

struct Shimmer_Previews: PreviewProvider {
    struct ShimmerPreview: View {
        @State var value = false

        let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

        var body: some View {
            Button(action: { value.toggle() }) {
                Label("Checkout", systemImage: "cart")
            }
            .buttonStyle(.borderedProminent)
            .changeEffect(.shimmer, value: value)
            .onReceive(timer) { _ in
                value.toggle()
            }
        }
    }

    static var previews: some View {
        ShimmerPreview()
    }
}
