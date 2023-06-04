
import SwiftUI
import Combine

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

    @State var stateValue: Value
    @State var changeCount: Int = 0
    @State var lastFired: Date = .distantPast

    init(value: Value, effect: Effect, isEnabled: Bool) {
        self.value = value
        self.effect = effect
        self.isEnabled = isEnabled
        self._stateValue = State(initialValue: value)
    }

    func body(content: Content) -> some View {
        content
            .modifier(effect.modifier(count: changeCount))
            .onChange(of: value) { stateValue = $0 } // By doing this we can access the oldValue in our onChange
            .onChange(of: stateValue) { [oldValue = stateValue] newValue in
                guard isEnabled, oldValue != newValue else { return }
                if Date.now.timeIntervalSince(lastFired) < effect.cooldown {
                    return
                }
                lastFired = .now
                changeCount &+= 1
            }
    }
}

struct ChangeEffectPreview<Content: View>: View {
    let fireFrequency: TimeInterval
    let timer: AnyPublisher<Date, Never>
    @ViewBuilder let content: (Binding<Date>) -> Content

    @State var value: Date = .now

    init(fireFrequency: TimeInterval = 3, @ViewBuilder content: @escaping (Binding<Date>) -> Content) {
        self.fireFrequency = fireFrequency
        self.timer = Timer.publish(every: fireFrequency, on: .main, in: .common).autoconnect().eraseToAnyPublisher()
        self.content = content
    }

    var body: some View {
        VStack {
            TimelineView(.animation) { tl in
                let seconds = value.addingTimeInterval(fireFrequency).timeIntervalSince(tl.date)
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
