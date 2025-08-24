//
//  ClipboardWatcher.swift
//  clipboard-manager
//
//  Created by Richard Hull on 24/08/2025.
//

import AppKit

class ClipboardWatcher: ObservableObject {
    @Published var history: [ClipboardItem] = []
    
    private let pb = NSPasteboard.general
    private var lastChangeCount = NSPasteboard.general.changeCount
    private var timer: Timer?
    
    init() {
        start()
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.check()
        }
    }
    
    private func check() {
        guard pb.changeCount != lastChangeCount else { return }
        lastChangeCount = pb.changeCount
        
        if let rtf = pb.data(forType: .rtf),
                  let attr = try? NSAttributedString(data: rtf,
                                                    options: [.documentType: NSAttributedString.DocumentType.rtf],
                                                    documentAttributes: nil) {
            addItem(.rtf(attr))
        } else if let str = pb.string(forType: .string) {
            addItem(.text(str))
        } else if let tiff = pb.data(forType: .tiff),
                  let img = NSImage(data: tiff) {
            addItem(.image(img))
        }
    }
    
    private func addItem(_ content: ClipboardContent) {
        history.insert(ClipboardItem(content: content, timestamp: Date()), at: 0)
        if history.count > 5 { history.removeLast() }
    }
}
