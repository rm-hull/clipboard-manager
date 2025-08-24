//
//  ClipboardPicker.swift
//  clipboard-manager
//
//  Created by Richard Hull on 24/08/2025.
//

import SwiftUI

struct ClipboardPicker: View {
    @ObservedObject var watcher: ClipboardWatcher
    @Environment(\.dismiss) var dismiss
    @State private var selected: ClipboardItem.ID?
    var imgWidth: CGFloat = 200
    
    var body: some View {
        List(watcher.history, id: \.id, selection: $selected) { item in
            HStack {
                preview(for: item.content)
                Spacer()
                Text(item.timestamp, style: .time)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                choose(item)
            }
        }
        .frame(width: 400, height: 250)
        .onAppear {
            if let first = watcher.history.first { selected = first.id }
        }
        .onExitCommand { dismiss() } // ESC closes
        .onKeyPress(.return) { // custom key handling
            if let sel = watcher.history.first(where: { $0.id == selected }) {
                choose(sel)
            }
            return KeyPress.Result.handled
        }
    }
    
    @ViewBuilder
    func preview(for content: ClipboardContent) -> some View {
        switch content {
        case .text(let s):
            Text(s).lineLimit(1)
        case .rtf(let attr):
            Text(attr.string).lineLimit(1).italic()
        case .image(let img):
            Image(nsImage: img)
                .resizable()
                .frame(width: imgWidth, height: imgWidth * img.size.height / img.size.width)
        }
    }
    
    func choose(_ item: ClipboardItem) {
        let pb = NSPasteboard.general
        pb.clearContents()
        switch item.content {
        case .text(let s):
            pb.setString(s, forType: .string)
        case .rtf(let attr):
            if let rtf = try? attr.data(from: NSRange(location: 0, length: attr.length),
                                        documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf]) {
                pb.setData(rtf, forType: .rtf)
            }
        case .image(let img):
            if let tiff = img.tiffRepresentation {
                pb.setData(tiff, forType: .tiff)
            }
        }
        // Simulate ⌘V (paste)
        let src = CGEventSource(stateID: .hidSystemState)
        let vDown = CGEvent(keyboardEventSource: src, virtualKey: 9, keyDown: true) // v key
        let vUp   = CGEvent(keyboardEventSource: src, virtualKey: 9, keyDown: false)
        vDown?.flags = .maskCommand
        vDown?.post(tap: .cghidEventTap)
        vUp?.post(tap: .cghidEventTap)
        dismiss()
    }
}

extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}
