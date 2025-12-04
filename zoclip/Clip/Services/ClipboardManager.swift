//
//  ClipboardManager.swift
//  zoclip
//
//  Created by zzh on 2025/12/3.
//

import AppKit
import Combine
import Foundation

class ClipboardManager: ObservableObject {
    static let shared = ClipboardManager()

    @Published var history: [ClipItem] = []
    @Published var maxLimit: Int = 100
    private var timer: Timer?
    private var lastChangeCount = NSPasteboard.general.changeCount
    private func baseFolder() -> URL {
        let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("zoclip", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func imageFolder() -> URL {
        let url = baseFolder().appendingPathComponent("images", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    private func historyURL() -> URL {
        baseFolder().appendingPathComponent("history.json")
    }

    private init() {
        loadHistory()
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
            if let str = pb.string(forType: .string) {
                let item = ClipItem(
                    id: UUID(),
                    type: .text,
                    text: str,
                    imagePath: nil,
                    timestamp: .now
                )
                addItem(item)
            }
            if let image = NSImage(pasteboard: pb) {
                let id = UUID()
                let file = imageFolder().appendingPathComponent(id.uuidString + ".png")
                saveImage(image, to: file)

                let item = ClipItem(
                    id: id,
                    type: .image,
                    text: nil,
                    imagePath: file.path,
                    timestamp: .now
                )
                addItem(item)
            }
        }
    }

    func addItem(_ item: ClipItem) {
        // 去重：删掉相同内容或相同图片
        history.removeAll { old in
            (item.text != nil && item.text == old.text)
                || (item.imagePath != nil && item.imagePath == old.imagePath)
        }

        history.insert(item, at: 0)

        if history.count > maxLimit {
            history.removeLast(history.count - maxLimit)
        }

        saveHistory()
    }

    func copy(_ item: ClipItem) {
        NSPasteboard.general.clearContents()

        switch item.type {
        case .text:
            if let text = item.text {
                NSPasteboard.general.setString(text, forType: .string)
            }

        case .image:
            if let path = item.imagePath,
               let nsImage = NSImage(contentsOfFile: path)
            {
                NSPasteboard.general.writeObjects([nsImage])
            }

        default:
            break
        }
    }

    func delete(_ item: ClipItem) {
        history.removeAll { $0.id == item.id }
        saveHistory()
    }

    func saveImage(_ image: NSImage, to url: URL) {
        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: .png, properties: [:]) else { return }

        try? png.write(to: url)
    }

    func saveHistory() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(history)
            try data.write(to: historyURL())
        } catch {
            print("保存失败：\(error)")
        }
    }

    func loadHistory() {
        let file = historyURL()
        guard FileManager.default.fileExists(atPath: file.path) else { return }

        do {
            let data = try Data(contentsOf: file)
            let decoded = try JSONDecoder().decode([ClipItem].self, from: data)
            history = decoded
        } catch {
            print("读取失败：\(error)")
        }
    }
}
