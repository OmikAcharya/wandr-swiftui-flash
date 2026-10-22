import SwiftUI

public struct TagPillView: View {
    public let text: String
    public let color: Color

    public init(text: String, color: Color = .blue) {
        self.text = text.starts(with: "#") ? text : "#\(text)"
        self.color = color
    }

    public var body: some View {
        Text(text)
            .font(.caption2.weight(.medium))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}
