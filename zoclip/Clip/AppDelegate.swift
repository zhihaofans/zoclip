//
//  AppDelegate.swift
//  zoclip
//
//  Created by zzh on 2025/12/3.
//

import AppKit
import Foundation
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 创建菜单栏图标
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: nil)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.action = #selector(statusItemClicked(_:))
        }

        // 设置弹窗内容（左键点击）
        popover.contentSize = NSSize(width: 400, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: HistoryView())
    }

    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }

    @objc func statusItemClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!

        if event.type == .rightMouseUp {
            showMenu()
        } else {
            togglePopover()
        }
    }

    @objc func clearHistory() {
        let manager = ClipboardManager.shared
        manager.history.removeAll()
        manager.saveHistory()
    }

    @objc func quitApp() {
        NSApp.terminate(nil)
    }

    func showMenu() {
        let menu = NSMenu()

        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "未知版本"
        menu.addItem(withTitle: "zoclip v\(version)", action: nil, keyEquivalent: "")

        menu.addItem(NSMenuItem.separator())

        menu.addItem(withTitle: "清空记录", action: #selector(clearHistory), keyEquivalent: "")
        menu.addItem(withTitle: "退出", action: #selector(quitApp), keyEquivalent: "")

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }
}
