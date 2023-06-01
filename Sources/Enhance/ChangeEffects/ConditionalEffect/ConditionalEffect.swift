
import SwiftUI

public protocol ConditionalEffect {
    associatedtype ResolvedModifier: ViewModifier

    var delay: TimeInterval { get }
    var defaultAnimation: Animation? { get }

    func modifier(isActive: Bool) -> ResolvedModifier
}

public extension View {
    func conditionalEffect(_ effect: some ConditionalEffect, condition: Bool, isEnabled: Bool = true, animation: Animation? = nil) -> some View {
        let modifier = ConditionalEffectModifier(effect: effect, isActive: condition && isEnabled)
            .transaction { transaction in
                transaction.animation = animation ?? effect.defaultAnimation ?? transaction.animation
                transaction.animation = transaction.animation?.delay(effect.delay)
            }
        return self.modifier(modifier)
    }
}

struct ConditionalEffectModifier<Effect: ConditionalEffect>: ViewModifier {
    let effect: Effect
    let isActive: Bool

    func body(content: Content) -> some View {
        let modifier = effect.modifier(isActive: isActive)
        return content.modifier(modifier)
    }
}
