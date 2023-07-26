
import SwiftUI

public protocol ConditionalEffect {
    associatedtype ResolvedModifier: ViewModifier

    var delay: TimeInterval { get }
    var defaultAnimation: Animation? { get }

    func modifier(isActive: Bool) -> ResolvedModifier
}

public extension View {
    func conditionalEffect(_ effect: some ConditionalEffect, condition: Bool, isEnabled: Bool = true, animation: Animation? = nil) -> some View {
        var animation = animation ?? effect.defaultAnimation
        if !effect.delay.isZero {
            animation = animation?.delay(effect.delay)
        }
        let modifier = ConditionalEffectModifier(isActive: condition && isEnabled, effect: effect, animation: animation)
        return self.modifier(modifier)
    }
}

struct ConditionalEffectModifier<Effect: ConditionalEffect>: ViewModifier {
    let isActive: Bool
    let effect: Effect
    let animation: Animation?

    @State var stateValue: Bool

    init(isActive: Bool, effect: Effect, animation: Animation?) {
        self.isActive = isActive
        self.effect = effect
        self.animation = animation
        self._stateValue = State(initialValue: isActive)
    }

    func body(content: Content) -> some View {
        content
            .modifier(effect.modifier(isActive: stateValue))
            .onChange(of: isActive) { [oldValue = isActive] newValue in
                guard oldValue != newValue && newValue != stateValue else { return }
                let transaction = Transaction(animation: animation)
                withTransaction(transaction) {
                    stateValue = newValue
                }
            }
    }
}
