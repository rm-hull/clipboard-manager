//
//  ClipboardItem.swift
//  clipboard-manager
//
//  Created by Richard Hull on 24/08/2025.
//

import AppKit

enum ClipboardContent {
    case text(String)
    case rtf(NSAttributedString)
    case image(NSImage)
}

struct ClipboardItem: Identifiable {
    let id = UUID()
    let content: ClipboardContent
    let timestamp: Date
}
