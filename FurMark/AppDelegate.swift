//
//  AppDelegate.swift
//  FurMark
//
//  Created by Keaton Burleson on 6/17/20.
//  Copyright © 2020 Keaton Burleson. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    @IBAction func downloadGpuTest(_ sender: NSMenuItem) {
        let downloadProcess = Process()
        downloadProcess.launchPath = "/bin/bash"
        downloadProcess.arguments = ["\(Bundle.main.path(forResource: "download_gputest", ofType: ".sh")!)"]
        downloadProcess.waitUntilExit()
        downloadProcess.launch()

        let alert = NSAlert()
        alert.messageText = "Downloaded GpuTest"
        alert.informativeText = "GpuTest has been downloaded to '~/Applications/GpuTest'"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Show me")

        let result = alert.runModal()

        if (result != .OK) {
            let downloadDir = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications").appendingPathComponent("GpuTest", isDirectory: true)
            NSWorkspace.shared.open(downloadDir)
        }
    }
}

