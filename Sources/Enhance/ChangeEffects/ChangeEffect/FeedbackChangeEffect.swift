
import SwiftUI
import UIKit

// MARK: - Selection Feedback

public struct SelectionFeedbackChangeEffect: ChangeEffect {
    public var generator = UISelectionFeedbackGenerator()

    public func modifier(count: Int) -> some ViewModifier {
        Modifier(generator: generator, value: count)
    }

    struct Modifier: ViewModifier {
        let generator: UISelectionFeedbackGenerator
        let value: Int

        func body(content: Content) -> some View {
            content
                .onAppear { generator.prepare() }
                .onChange(of: value) { newValue in
                    generator.selectionChanged()
                    generator.prepare() // Keep the generator ready
                }
        }
    }
}

public extension ChangeEffect where Self == SelectionFeedbackChangeEffect {
    static var feedbackHapticSelection: SelectionFeedbackChangeEffect { SelectionFeedbackChangeEffect() }
}

// MARK: - Impact Feedback

public struct ImpactFeedbackChangeEffect: ChangeEffect {
    public var intensity: CGFloat?
    public var generator: UIImpactFeedbackGenerator

    public init() {
        self.intensity = nil
        self.generator = UIImpactFeedbackGenerator()
    }

    public init(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        self.intensity = nil
        self.generator = UIImpactFeedbackGenerator(style: style)
    }

    public init(intensity: CGFloat) {
        self.generator = UIImpactFeedbackGenerator()
        self.intensity = intensity
    }

    public func modifier(count: Int) -> some ViewModifier {
        Modifier(generator: generator, intensity: intensity, value: count)
    }

    struct Modifier: ViewModifier {
        let generator: UIImpactFeedbackGenerator
        let intensity: CGFloat?
        let value: Int

        func body(content: Content) -> some View {
            content
                .onAppear { generator.prepare() }
                .onChange(of: value) { newValue in
                    if let intensity {
                        generator.impactOccurred(intensity: intensity)
                    } else {
                        generator.impactOccurred()
                    }
                    generator.prepare() // Keep the generator ready
                }
        }
    }
}

public extension ChangeEffect where Self == ImpactFeedbackChangeEffect {
    static var feedbackHapticImpact: Self { Self() }

    static func feedbackHapticImpact(intensity: CGFloat) -> Self {
        Self(intensity: intensity)
    }

    static func feedbackHapticImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) -> Self {
        Self(style: style)
    }
}

// MARK: - Notification Feedback

public struct NotificationFeedbackChangeEffect: ChangeEffect {
    public var type: UINotificationFeedbackGenerator.FeedbackType
    public var generator = UINotificationFeedbackGenerator()

    public func modifier(count: Int) -> some ViewModifier {
        Modifier(generator: generator, type: type, value: count)
    }

    struct Modifier: ViewModifier {
        let generator: UINotificationFeedbackGenerator
        let type: UINotificationFeedbackGenerator.FeedbackType
        let value: Int

        func body(content: Content) -> some View {
            content
                .onAppear { generator.prepare() }
                .onChange(of: value) { newValue in
                    generator.notificationOccurred(type)
                }
        }
    }
}

public extension ChangeEffect where Self == NotificationFeedbackChangeEffect {
    static func feedbackHapticNotification(type: UINotificationFeedbackGenerator.FeedbackType) -> Self {
        Self(type: type)
    }
}
