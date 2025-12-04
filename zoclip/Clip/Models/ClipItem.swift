//
//  ClipItem.swift
//  zoclip
//
//  Created by zzh on 2025/12/4.
//

import Foundation

struct ClipItem: Codable, Hashable, Identifiable {
    let id: UUID
    let type: ClipType
    let text: String?
    let imagePath: String?
    let timestamp: Date
}

enum ClipType: String, Codable {
    case text
    case image
    case unknown
}
