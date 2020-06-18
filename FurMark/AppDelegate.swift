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
}

