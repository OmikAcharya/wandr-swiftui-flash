import Foundation
import SwiftUI

public struct MemoryPhoto: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var presetName: String?
    public var imageData: Data?
    public var caption: String?
    public var dateTaken: Date

    public init(
        id: UUID = UUID(),
        presetName: String? = nil,
        imageData: Data? = nil,
        caption: String? = nil,
        dateTaken: Date = Date()
    ) {
        self.id = id
        self.presetName = presetName
        self.imageData = imageData
        self.caption = caption
        self.dateTaken = dateTaken
    }

    public var hasImage: Bool {
        return (presetName != nil && !(presetName?.isEmpty ?? true)) || (imageData != nil && !(imageData?.isEmpty ?? true))
    }
}
