
import SwiftUI

public protocol ChangeEffect {
    associatedtype ResolvedModifier: ViewModifier

    var delay: TimeInterval { get }
    var cooldown: TimeInterval { get }
    var defaultAnimation: Animation? { get }

    func modifier(count: Int) -> ResolvedModifier
}

public extension View {

    /**
     Use this function to apply a change effect to a `View`. Change effects are typically visual modifications that can be applied to a
     view, such as scaling, rotation, or opacity changes. The `effect` parameter specifies the type of change effect to apply, while the
     `value` parameter changing triggers the effect.

     - Parameters:
         - effect: The change effect to apply.
         - value: The value whose change triggers the change effect.
         - isEnabled: A Boolean value indicating whether the effect is enabled. Default value is `true`.
         - animation: The animation to use for the effect. If `nil` the `effect.defaultAnimation` will be used.

     - Returns: A modified view with the `ChangeEffect` applied.

     - SeeAlso: ``ChangeEffect``
     */
    func changeEffect(_ effect: some ChangeEffect, value: some Equatable, isEnabled: Bool = true, animation: Animation? = nil) -> some View {
        let modifier = ChangeEffectModifier(value: value, effect: effect, isEnabled: isEnabled)
            .transaction { transaction in
                transaction.animation = animation ?? effect.defaultAnimation ?? transaction.animation
                transaction.animation = transaction.animation?.delay(effect.delay)
            }
        return self.modifier(modifier)
    }
}

struct ChangeEffectModifier<Value: Equatable, Effect: ChangeEffect>: ViewModifier {
    let value: Value
    let effect: Effect
    let isEnabled: Bool

    @State var changeCount: Int = 0
    @State var lastFired: Date = .distantPast

    func body(content: Content) -> some View {
        content
            .modifier(effect.modifier(count: changeCount))
            .onChange(of: value) { newValue in
                guard newValue != value && isEnabled else { return }
                if Date.now.timeIntervalSince(lastFired) < effect.cooldown {
                    return
                }
                lastFired = .now
                changeCount &+= 1
            }
    }
}

struct ChangeEffectPreview<Content: View>: View {
    @State var value: Date = .now

    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    @ViewBuilder let content: (Binding<Date>) -> Content

    var body: some View {
        VStack {
            TimelineView(.animation) { tl in
                let seconds = value.addingTimeInterval(3).timeIntervalSince(tl.date)
                if #available(iOS 16, *) {
                    Text("Fires in \(seconds, format: .number.precision(.fractionLength(2))) seconds").contentTransition(.numericText(countsDown: true))
                        .foregroundColor(seconds < (5 / 60) ? .green : .primary)
                } else {
                    Text("Fires in \(seconds) seconds")
                }
            }
            content($value).onReceive(timer, perform: { value = $0 })
        }
    }
}
