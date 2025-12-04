//
//  ClipboardManager.swift
//  zoclip
//
//  Created by zzh on 2025/12/3.
//

import Foundation
import AppKit
import Combine

class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()

    @Published var history: [String] = []
    @Published var maxLimit: Int = 100
    private var timer: Timer?
    private var lastChangeCount = NSPasteboard.general.changeCount

    private init() {
        start()
    }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { _ in
            self.check()
        }
    }

    func check() {
        let pb = NSPasteboard.general
        if pb.changeCount != lastChangeCount {
            lastChangeCount = pb.changeCount
            if let str = pb.string(forType: .string),
               str != history.first {

                // 去重：如果已有相同内容，则先删除旧的
                history.removeAll { $0 == str }
                history.insert(str, at: 0)

                // 限制记录上限
                if history.count > maxLimit {
                    history.removeLast(history.count - maxLimit)
                }
            }
        }
    }

    func copy(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }

    func delete(_ text: String) {
        history.removeAll { $0 == text }
    }
}
