//
//  ClipboardItem.swift
//  clipboard-manager
//
//  Created by Richard Hull on 24/08/2025.
//

import AppKit

enum ClipboardContent: Equatable {
    case text(String)
    case rtf(NSAttributedString)
    case image(NSImage)
    
    static func == (lhs: ClipboardContent, rhs: ClipboardContent) -> Bool {
        switch (lhs, rhs) {
        case let (.text(a), .text(b)):
            return a.trimmingCharacters(in: .whitespacesAndNewlines) == b.trimmingCharacters(in: .whitespacesAndNewlines)

        case let (.rtf(a), .rtf(b)):
            return a.string.trimmingCharacters(in: .whitespacesAndNewlines) == b.string.trimmingCharacters(in: .whitespacesAndNewlines)

        case let (.image(a), .image(b)):
            // Option 1: Compare size + tiffRepresentation
            return a.size == b.size &&
                   a.tiffRepresentation == b.tiffRepresentation

        default:
            return false
        }
    }
}

struct ClipboardItem: Identifiable {
    let id = UUID()
    let content: ClipboardContent
    let timestamp: Date
}
