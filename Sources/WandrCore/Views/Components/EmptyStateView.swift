import SwiftUI

public struct EmptyStateView: View {
    public let icon: String
    public let title: String
    public let message: String
    public let buttonTitle: String?
    public let action: (() -> Void)?

    public init(
        icon: String = "map",
        title: String,
        message: String,
        buttonTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.wandrAccent.opacity(0.12))
                    .frame(width: 84, height: 84)

                Image(systemName: icon)
                    .font(.system(size: 38))
                    .foregroundColor(Color.wandrAccent)
            }
            .padding(.bottom, 8)

            Text(title)
                .font(.title3.weight(.bold))
                .foregroundColor(.primary)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            if let buttonTitle = buttonTitle, let action = action {
                Button(action: action) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                        Text(buttonTitle)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.wandrAccent)
                    .clipShape(Capsule())
                    .shadow(color: Color.wandrAccent.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }
}
