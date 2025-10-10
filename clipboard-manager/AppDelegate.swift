//
//  clipboard_managerApp.swift
//  clipboard-manager
//
//  Created by Richard Hull on 24/08/2025.
//

import Cocoa
import SwiftUI

//@main
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var watcher = ClipboardWatcher()
    var window: NSWindow?
    var statusItem: NSStatusItem?
    var hotkeyListener: HotkeyListener?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        hotkeyListener = HotkeyListener()
        NotificationCenter.default.addObserver(forName: .hotkeyPressed, object: nil, queue: .main) { _ in
            self.showPopup()
        }
    }
    
    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard Manager")
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show Clipboard History", action: #selector(showPopupFromMenu), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        statusItem?.menu = menu
    }

    @objc func showPopupFromMenu() {
        showPopup()
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }

    @objc func windowWillClose(_ notification: Notification) {
        window = nil
    }
    
    func showPopup() {
        if let window = self.window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let picker = ClipboardPicker(watcher: watcher)
        let vc = NSHostingController(rootView: picker)
        let w = NSWindow(contentViewController: vc)

        w.title = "Clipboard Manager"
        w.styleMask = [.titled, .closable]
        w.level = .floating   // make sure it appears above apps
        w.center()
        w.delegate = self
        w.makeKeyAndOrderFront(nil)

        NSApp.activate(ignoringOtherApps: true)
        self.window = w
    }
}
