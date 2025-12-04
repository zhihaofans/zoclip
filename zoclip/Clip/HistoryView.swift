//
//  HistoryView.swift
//  zoclip
//
//  Created by zzh on 2025/12/3.
//

import Foundation
import SwiftUI

struct HistoryView: View {
    @ObservedObject var manager = ClipboardManager.shared
    @State private var search = ""

    var body: some View {
        VStack {
            TextField("搜索剪贴板内容…", text: $search)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            HStack {
                Text("记录上限：")
                TextField("", text: Binding(
                    get: { String(manager.maxLimit) },
                    set: { value in
                        if let v = Int(value) {
                            // 限制范围在 10 到 500 之间
                            manager.maxLimit = min(max(v, 10), 500)
                        }
                    }
                ))
                .frame(width: 60)
                .textFieldStyle(RoundedBorderTextFieldStyle())

                Slider(value: Binding(
                    get: { Double(manager.maxLimit) },
                    set: { manager.maxLimit = Int($0) }
                ), in: 10...500)
            }
            .padding(.horizontal)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(filtered, id: \.self) { item in
                        HStack {
                            Button(action: {
                                manager.copy(item)
                            }) {
                                Text(item)
                                    .lineLimit(2)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Button(action: {
                                manager.delete(item)
                            }) {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding(.vertical, 4)
                        Divider()
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .frame(minWidth: 300, minHeight: 400)
    }

    private var filtered: [String] {
        if search.isEmpty { return manager.history }
        return manager.history.filter { $0.localizedCaseInsensitiveContains(search) }
    }
}
