
import SwiftUI

public extension Animation {

    /// Mostly derived from the values at https://easings.net

    static var easeInCircular: Animation { .timingCurve(0.55, 0, 1, 0.45) }
    static var easeOutCircular: Animation { .timingCurve(0, 0.55, 0.45, 1) }
    static var easeInOutCircular: Animation { .timingCurve(0.85, 0, 0.15, 1) }
    static func easeInCircular(duration: Double) -> Animation { .timingCurve(0.55, 0, 1, 0.45, duration: duration) }
    static func easeOutCircular(duration: Double) -> Animation { .timingCurve(0, 0.55, 0.45, 1, duration: duration) }
    static func easeInOutCircular(duration: Double) -> Animation { .timingCurve(0.85, 0, 0.15, 1, duration: duration) }

    static var easeInQuint: Animation { .timingCurve(0.64, 0, 0.78, 0) }
    static var easeOutQuint: Animation { .timingCurve(0.22, 1, 0.36, 1) }
    static var easeInOutQuint: Animation { .timingCurve(0.83, 0, 0.17, 1) }
    static func easeInQuint(duration: Double) -> Animation { .timingCurve(0.64, 0, 0.78, 0, duration: duration) }
    static func easeOutQuint(duration: Double) -> Animation { .timingCurve(0.22, 1, 0.36, 1, duration: duration) }
    static func easeInOutQuint(duration: Double) -> Animation { .timingCurve(0.83, 0, 0.17, 1, duration: duration) }

    static var easeInExponential: Animation { .timingCurve(0.7, 0, 0.84, 0) }
    static var easeOutExponential: Animation { .timingCurve(0.16, 1, 0.3, 1) }
    static var easeInOutExponential: Animation { .timingCurve(0.87, 0, 0.13, 1) }
    static func easeInExponential(duration: Double) -> Animation { .timingCurve(0.7, 0, 0.84, 0, duration: duration) }
    static func easeOutExponential(duration: Double) -> Animation { .timingCurve(0.16, 1, 0.3, 1, duration: duration) }
    static func easeInOutExponential(duration: Double) -> Animation { .timingCurve(0.87, 0, 0.13, 1, duration: duration) }

    static var easeInBack: Animation { .timingCurve(0.36, 0, 0.66, -0.56) }
    static var easeOutBack: Animation { .timingCurve(0.34, 1.56, 0.64, 1) }
    static var easeInOutBack: Animation { .timingCurve(0.68, -0.6, 0.32, 1.6) }
    static func easeInBack(duration: Double) -> Animation { .timingCurve(0.36, 0, 0.66, -0.56, duration: duration) }
    static func easeOutBack(duration: Double) -> Animation { .timingCurve(0.34, 1.56, 0.64, 1, duration: duration) }
    static func easeInOutBack(duration: Double) -> Animation { .timingCurve(0.68, -0.6, 0.32, 1.6, duration: duration) }
}
