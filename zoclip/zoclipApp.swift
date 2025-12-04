//
//  zoclipApp.swift
//  zoclip
//
//  Created by zzh on 2025/12/3.
//
import SwiftUI

@main
struct zoclipApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
