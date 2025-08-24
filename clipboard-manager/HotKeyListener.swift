//
//  HotKeyListener.swift
//  clipboard-manager
//
//  Created by Richard Hull on 24/08/2025.
//

import Cocoa

class HotkeyListener {
    private var eventTap: CFMachPort?

    init() {
        setupEventTap()
    }
    
    private func setupEventTap() {
        // Check if we have accessibility permissions
        let trusted = AXIsProcessTrustedWithOptions([
            kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true
        ] as CFDictionary)
        
        guard trusted else {
            print("Accessibility permissions not granted. Please grant permissions in System Preferences.")
            return
        }
        
        let mask = (1 << CGEventType.keyDown.rawValue)
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: { proxy, type, event, refcon in
                if type == .keyDown {
                    let flags = event.flags.intersection(.maskCommand.union(.maskShift))
                    if event.getIntegerValueField(.keyboardEventKeycode) == 9,  // V key
                       flags.contains(.maskCommand) && flags.contains(.maskShift) {
                        DispatchQueue.main.async {
                            (Unmanaged<HotkeyListener>.fromOpaque(refcon!).takeUnretainedValue()).trigger()
                        }
                        return nil
                    }
                }
                return Unmanaged.passRetained(event)
            },
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )
        
        guard let eventTap = eventTap else {
            print("Failed to create event tap. Make sure the app has accessibility permissions.")
            return
        }
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        guard runLoopSource != nil else {
            print("Failed to create run loop source")
            return
        }
        
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        print("Hotkey listener setup successfully")
    }

    func trigger() {
        NotificationCenter.default.post(name: .hotkeyPressed, object: nil)
    }
    
    deinit {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            CFMachPortInvalidate(eventTap)
        }
    }
}

extension Notification.Name {
    static let hotkeyPressed = Notification.Name("HotkeyPressed")
}
