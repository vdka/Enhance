
import SwiftUI

public protocol ConditionalEffect {
    associatedtype ResolvedModifier: ViewModifier
    func modifier(isActive: Bool) -> ResolvedModifier
}

public extension View {
    func conditionalEffect(_ effect: some ConditionalEffect, condition: Bool, isEnabled: Bool = true) -> some View {
        self.modifier(ConditionalEffectModifier(effect: effect, isActive: condition && isEnabled))
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
