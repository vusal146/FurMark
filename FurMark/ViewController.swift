//
//  ViewController.swift
//  FurMark
//
//  Created by Keaton Burleson on 6/17/20.
//  Copyright © 2020 Keaton Burleson. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var minutesLabel: NSTextField?
    @IBOutlet var timeLimitField: NSTextField?
    @IBOutlet var timeLimitStepper: NSStepper?
    @IBOutlet var testPopupButton: NSPopUpButton?
    @IBOutlet var hideScoreDialogButton: NSButton?
    
    @IBOutlet var useFullscreenButton: NSButton?
    @IBOutlet var useAntialiasingButton: NSButton?
    @IBOutlet var useTimeLimitButton: NSButton?
    


    var useFullscreen = false
    var hideScoreDialog = false
    var useAntialiasing = false
    var useTimeLimit = false

    var timeLimit: Int = 15
    var tests = ["Furry Donut": "fur",
        "TessMark x64": "tess_x64",
        "TessMark x32": "tess_x32",
        "Plot3D": "plot3d",
        "Triangle": "triangle",
        "Volplosion": "pixmark_volplosion",
        "Piano": "pixmark_piano",
        "GI": "gi"
    ]
    var selectedTest = "fur"
    var soundTimer: Timer? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.testPopupButton?.removeAllItems()

        let testNames = self.tests.keys.sorted { $0 < $1 }
        testNames.forEach {
            self.testPopupButton?.addItem(withTitle: $0)
        }

        self.readUserDefaults()
       
    }


    @IBAction func setUseFullscreen(_ sender: NSButton) {
        self.useFullscreen = sender.state == .on
        UserDefaults.standard.set(self.useFullscreen, forKey: "useFullscreen")
    }

    @IBAction func setHideScoreDialog(_ sender: NSButton) {
        self.hideScoreDialog = sender.state == .on
        UserDefaults.standard.set(self.hideScoreDialog, forKey: "hideScoreDialog")
    }

    @IBAction func setUseAntialiasing(_ sender: NSButton) {
        self.useAntialiasing = sender.state == .on
        UserDefaults.standard.set(self.useAntialiasing, forKey: "useAntialiasing")
    }

    @IBAction func setUseTimeLimit(_ sender: NSButton) {
        self.useTimeLimit = sender.state == .on

        self.hideScoreDialogButton?.isEnabled = self.useTimeLimit

        
        self.timeLimitField?.isEnabled = self.useTimeLimit
        self.timeLimitStepper?.isEnabled = self.useTimeLimit
        self.timeLimitField?.integerValue = self.timeLimit
        self.timeLimitStepper?.integerValue = self.timeLimit
        
        if (!self.useTimeLimit) {
            self.hideScoreDialog = false
            self.hideScoreDialogButton?.state = .off
        }
        

        UserDefaults.standard.set(self.useTimeLimit, forKey: "useTimeLimit")
        UserDefaults.standard.set(self.timeLimit, forKey: "timeLimit")
        UserDefaults.standard.set(self.hideScoreDialog, forKey: "hideScoreDialog")
    }

    @IBAction func stepperValueChanged(_ sender: NSStepper) {
        if (sender.integerValue >= 0) {
            self.timeLimitField?.integerValue = sender.integerValue
            self.timeLimit = sender.integerValue
            UserDefaults.standard.set(self.timeLimit, forKey: "timeLimit")

            if (self.timeLimit == 1) {
                self.minutesLabel?.stringValue = "minute"
            } else {
                self.minutesLabel?.stringValue = "minutes"
            }
        }
    }

    @IBAction func testDropdownValueChanged(_ sender: NSPopUpButton) {
        self.selectedTest = self.tests[sender.selectedItem!.title]!
        UserDefaults.standard.set(sender.selectedItem!.title, forKey: "lastTest")
    }

    @IBAction func startTest(_ sender: NSButton) {
        var args: [String] = ["/test=\(self.selectedTest)"]
        let appURL = URL(fileURLWithPath: "/Applications/GpuTest.app")

        self.timeLimit = self.timeLimitField!.integerValue

        if (self.quitRunningTest()) {
            sleep(1)
        }

        if (self.useFullscreen) {
            args.append("/fullscreen")
        }

        if (self.useAntialiasing) {
            args.append("/msaa=4")
        } else {
            args.append("/msaa=0")
        }

        if (self.hideScoreDialog) {
            args.append("/no_scorebox")
        }

        if (self.useTimeLimit && self.timeLimit > 0) {
            let ms = self.timeLimit * 60000

            args.append("/benchmark")
            args.append("/benchmark_duration_ms=\(ms)")
        }


        let configuration = NSWorkspace.OpenConfiguration()
        configuration.arguments = args

        NSWorkspace.shared.openApplication(at: appURL, configuration: configuration)

        if (self.useTimeLimit && self.timeLimit > 0) {
            self.soundTimer = Timer.scheduledTimer(timeInterval: TimeInterval((self.timeLimit * 60) + 5), target: self, selector: #selector(self.notifyComplete), userInfo: nil, repeats: false)
        }
    }
    
    func readUserDefaults() {
        self.useFullscreen = UserDefaults.standard.bool(forKey: "useFullscreen")
        self.useTimeLimit = UserDefaults.standard.bool(forKey: "useTimeLimit")
        self.useAntialiasing = UserDefaults.standard.bool(forKey: "useAntialiasing")
        self.hideScoreDialog = UserDefaults.standard.bool(forKey: "hideScoreDialog")
        
        self.useFullscreenButton?.state = self.useFullscreen ? .on : .off
        self.useTimeLimitButton?.state = self.useTimeLimit ? .on : .off
        self.useAntialiasingButton?.state = self.useAntialiasing ? .on : .off
        self.hideScoreDialogButton?.state = self.hideScoreDialog ? .on : .off
        
        if (UserDefaults.standard.integer(forKey: "timeLimit") > 0) {
            self.timeLimit = UserDefaults.standard.integer(forKey: "timeLimit")
            self.timeLimitStepper?.integerValue = self.timeLimit

            if (self.useTimeLimit) {
                self.timeLimitField?.integerValue = self.timeLimit
                self.timeLimitStepper?.isEnabled = true
                self.timeLimitField?.isEnabled = true
                self.hideScoreDialogButton?.isEnabled = true
            }
            
            if (self.timeLimit == 1) {
                self.minutesLabel?.stringValue = "minute"
            } else {
                self.minutesLabel?.stringValue = "minutes"
            }
        }
        
        if let lastTest = UserDefaults.standard.object(forKey: "lastTest") as? String {
            self.testPopupButton?.selectItem(withTitle: lastTest)
            self.selectedTest = lastTest
        } else {
             self.testPopupButton?.selectItem(withTitle: "Furry Donut")
        }
    }

    func quitRunningTest() -> Bool {
        if let currentTimer = self.soundTimer {
            currentTimer.invalidate()
            self.soundTimer = nil
        }

        let runningApplications = NSWorkspace.shared.runningApplications
        let potentialRunningTest = runningApplications.first { (app) -> Bool in
            return app.bundleIdentifier == "Geeks3D.GpuTest"
        }

        guard let runningTest = potentialRunningTest else {
            return false
        }

        runningTest.forceTerminate()

        return true
    }

    @objc func notifyComplete() {
        DispatchQueue.main.async {
            NSApp.activate(ignoringOtherApps: true)
            NSSound(named: "Purr")?.play()
            self.displayFinishedDialog()
        }
    }

    func displayFinishedDialog() {
        let alert = NSAlert()
        alert.messageText = "Finished Test"
        alert.informativeText = "GPU testing has finished after \(self.timeLimit) \(self.timeLimit == 1 ? "minute" : "minutes")."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

}

