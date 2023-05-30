
import Foundation

@inline(__always)
public func lerp<V: BinaryFloatingPoint, T: BinaryFloatingPoint>(t: T, _ v0: V, _ v1: V) -> V {
    return v0 + V(t) * (v1 - v0)
}

@inline(__always)
public func clamp<T: Comparable>(_ value: T, minValue: T, maxValue: T) -> T {
    return min(max(value, minValue), maxValue)
}
