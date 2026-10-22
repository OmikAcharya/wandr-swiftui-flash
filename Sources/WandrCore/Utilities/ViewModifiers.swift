import SwiftUI

public struct WandrCardModifier: ViewModifier {
    public var cornerRadius: CGFloat
    public var padding: CGFloat

    public init(cornerRadius: CGFloat = 16, padding: CGFloat = 16) {
        self.cornerRadius = cornerRadius
        self.padding = padding
    }

    public func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.wandrCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.primary.opacity(0.04), lineWidth: 1)
            )
    }
}

public extension View {
    func wandrCard(cornerRadius: CGFloat = 16, padding: CGFloat = 16) -> some View {
        self.modifier(WandrCardModifier(cornerRadius: cornerRadius, padding: padding))
    }
}
