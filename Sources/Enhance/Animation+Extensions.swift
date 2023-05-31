
import SwiftUI

public extension Animation {

    /// Mostly derived from the values at https://easings.net

    static var easeInCircular: Animation { .timingCurve(0.55, 0, 1, 0.45) }
    static var easeOutCircular: Animation { .timingCurve(0, 0.55, 0.45, 1) }
    static var easeInOutCircular: Animation { .timingCurve(0.85, 0, 0.15, 1) }

    static var easeInQuint: Animation { .timingCurve(0.64, 0, 0.78, 0) }
    static var easeOutQuint: Animation { .timingCurve(0.22, 1, 0.36, 1) }
    static var easeInOutQuint: Animation { .timingCurve(0.83, 0, 0.17, 1) }

    static var easeInExponential: Animation { .timingCurve(0.7, 0, 0.84, 0) }
    static var easeOutExponential: Animation { .timingCurve(0.16, 1, 0.3, 1) }
    static var easeInOutExponential: Animation { .timingCurve(0.87, 0, 0.13, 1) }

    static var easeInBack: Animation { .timingCurve(0.36, 0, 0.66, -0.56) }
    static var easeOutBack: Animation { .timingCurve(0.34, 1.56, 0.64, 1) }
    static var easeInOutBack: Animation { .timingCurve(0.68, -0.6, 0.32, 1.6) }

    /// A fairly interactive spring animation with much less damping resulting in it being a lot more **bouncy**
    static var bouncy: Animation { .interactiveSpring(response: 0.25, dampingFraction: 0.3) }
}

internal extension ViewModifier {
    func defaultAnimation(_ defaultAnimation: Animation) -> some ViewModifier {
        self.transaction { transaction in
            if let animation = transaction.animation {
                transaction.animation = animation.isDefaultButtonAnimation ? defaultAnimation : animation
                return
            }
            transaction.animation = defaultAnimation
        }
    }
}

internal extension Animation {
    // Only way to detect this that I could think of
    var isDefaultButtonAnimation: Bool {
        debugDescription.contains("ax: 1.0, bx: -0.75, cx: 0.75, ay: -1.7000000000000004, by: 2.4000000000000004, cy: 0.30000000000000004")
    }
}