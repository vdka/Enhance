
import SwiftUI

public extension View {
    func cornerRadius(_ radius: CGFloat, corners: PartRoundedRectangle.Corners) -> some View {
        clipShape(PartRoundedRectangle(radius: radius, corners: corners))
    }
}

public struct PartRoundedRectangle: Shape {
    public var radius: CGFloat = .infinity
    public var corners: Corners = .all

    @Environment(\.layoutDirection) var layoutDirection

    public init(radius: CGFloat, corners: Corners) {
        self.radius = radius
        self.corners = corners
    }

    public func path(in rect: CGRect) -> Path {
        let corners = uiRectCorner(for: self.corners)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }

    private func uiRectCorner(for corner: Corners) -> UIRectCorner {
        var corner = corner
        if corner.contains(.respectsLayoutDirectionFlag) {
            switch layoutDirection {
            case .leftToRight: break
            case .rightToLeft:
                // There is definitely a more cycle efficient way to do this, but this is easier to write
                var topLeft = corner.contains(.topLeft)
                var topRight = corner.contains(.topRight)
                var botLeft = corner.contains(.bottomLeft)
                var botRight = corner.contains(.bottomRight)
                swap(&topLeft, &topRight)
                swap(&botLeft, &botRight)

                corner = []
                corner.formUnion(topLeft ? .topLeft : [])
                corner.formUnion(topRight ? .topRight : [])
                corner.formUnion(botLeft ? .bottomLeft : [])
                corner.formUnion(botRight ? .bottomRight : [])

            @unknown default: break
            }
        }
        return UIRectCorner(rawValue: corner.rawValue & 0b1111)
    }

    public struct Corners: OptionSet {
        public let rawValue: UInt
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        public static var topLeft     = Self(rawValue: UIRectCorner.topLeft.rawValue)
        public static var topRight    = Self(rawValue: UIRectCorner.topRight.rawValue)
        public static var bottomLeft  = Self(rawValue: UIRectCorner.bottomLeft.rawValue)
        public static var bottomRight = Self(rawValue: UIRectCorner.bottomRight.rawValue)

        public static var topLeading     = topLeft.union(respectsLayoutDirectionFlag)
        public static var topTrailing    = topRight.union(respectsLayoutDirectionFlag)
        public static var bottomLeading  = bottomLeft.union(respectsLayoutDirectionFlag)
        public static var bottomTrailing = bottomRight.union(respectsLayoutDirectionFlag)

        public static var top: Self { [.topLeft, .topRight] }
        public static var bottom: Self { [.bottomLeft, .bottomRight] }
        public static var left: Self { [.topLeft, .bottomLeft] }
        public static var right: Self { [.topRight, .bottomRight] }
        public static var leading: Self { [.topLeading, .bottomLeading] }
        public static var trailing: Self { [.topTrailing, .bottomTrailing] }

        public static var all: Self { [.topLeft, .topRight, .bottomLeft, .bottomRight] }

        internal static var respectsLayoutDirectionFlag = Self(rawValue: 0b1 << 5)
    }
}
