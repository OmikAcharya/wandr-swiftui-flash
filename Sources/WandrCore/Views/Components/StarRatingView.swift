import SwiftUI

public struct StarRatingView: View {
    @Binding public var rating: Int
    public let maxRating: Int
    public let isInteractive: Bool
    public let size: CGFloat
    public let color: Color

    public init(
        rating: Binding<Int>,
        maxRating: Int = 5,
        isInteractive: Bool = true,
        size: CGFloat = 18,
        color: Color = .orange
    ) {
        self._rating = rating
        self.maxRating = maxRating
        self.isInteractive = isInteractive
        self.size = size
        self.color = color
    }

    public init(
        rating: Int,
        maxRating: Int = 5,
        size: CGFloat = 14,
        color: Color = .orange
    ) {
        self._rating = .constant(rating)
        self.maxRating = maxRating
        self.isInteractive = false
        self.size = size
        self.color = color
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundColor(star <= rating ? color : Color.secondary.opacity(0.3))
                    .onTapGesture {
                        if isInteractive {
                            rating = star
                        }
                    }
            }
        }
    }
}
