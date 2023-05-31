
import SwiftUI

struct RequiresConfirmationButtonStyle: PrimitiveButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        RequiresConfirmationButton(configuration: configuration)
    }

    struct RequiresConfirmationButton: View {
        let configuration: PrimitiveButtonStyleConfiguration

        @State var showConfirm = false

        var body: some View {
            Button(action: action) {
                ZStack {
                    if showConfirm {
                        Text("Confirm").transition(.opacity)
                    }
                    configuration.label.opacity(showConfirm ? 0 : 1)
                }
                .transaction { transaction in
                    transaction.animation = .easeInOut // Always use our own animation
                }
            }
        }

        func action() {
            if showConfirm {
                configuration.trigger()
            }
            showConfirm.toggle()
        }
    }
}

extension PrimitiveButtonStyle where Self == RequiresConfirmationButtonStyle {
    static var requiresConfirmation: Self { Self() }
}

public extension View {
    /// - Important: Must be applied to a button **before** any `buttonStyles`
    func buttonRequiresConfirmation() -> some View {
        buttonStyle(.requiresConfirmation)
    }
}

struct RequiresConfirmationButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button("Do thing!", action: { print("DOING THING") })
            .buttonStyle(.requiresConfirmation)
            .buttonStyle(.borderedProminent)
    }
}
