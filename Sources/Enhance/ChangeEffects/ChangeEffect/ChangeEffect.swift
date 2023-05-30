
import SwiftUI

public protocol ChangeEffect {
    associatedtype ResolvedModifier: ViewModifier
    func modifier(count: Int) -> ResolvedModifier
}

public extension View {
    func changeEffect<Value: Equatable>(_ effect: some ChangeEffect, value: Value, isEnabled: Bool = true ) -> some View {
        self.modifier(ChangeEffectModifier(value: value, effect: effect, isEnabled: isEnabled))
    }
}

struct ChangeEffectModifier<Value: Equatable, Effect: ChangeEffect>: ViewModifier {
    let value: Value
    let effect: Effect
    let isEnabled: Bool

    @State var changeCount: Int = 0

    func body(content: Content) -> some View {
        content
            .modifier(effect.modifier(count: changeCount))
            .onChange(of: value) { newValue in
                guard newValue != value && isEnabled else { return }
                changeCount &+= 1
            }
    }
}

struct ChangeEffectPreview<Effect: ChangeEffect>: View {
    let effect: Effect
    @State var value = 0

    var body: some View {
        VStack {
            Circle().fill(.red).frame(width: 30, height: 30)
                .changeEffect(effect, value: value)
            Button("Add", action: { value += 1 })
                .buttonStyle(.borderedProminent)
                .changeEffect(effect, value: value)
        }
    }
}
