//
// RemoteConfigViewController.swift
// FireAce
//
// Copyright (c) 2016 Hironori Ichimiya <hiron@hironytic.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import UIKit
import FirebaseRemoteConfig

class RemoteConfigViewController: UIViewController {
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!

    let remoteConfig = FIRRemoteConfig.remoteConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let remoteConfigSettings = FIRRemoteConfigSettings(developerModeEnabled: true) {
            remoteConfig.configSettings = remoteConfigSettings
        }
        
        remoteConfig.setDefaults([
            "type": "Type-A",
            "level": 1,
        ])
        
        updateValues()
    }

    @IBAction func fetchButtonTapped(sender: AnyObject) {
        remoteConfig.fetchWithExpirationDuration(10) { (status, error) in
            var statusText: String
            switch status {
            case .NoFetchYet:
                statusText = "NoFetchYet"
            case .Success:
                statusText = "Success"
            case .Failure:
                statusText = "Failure"
            case .Throttled:
                statusText = "Throttled"
            }
            print("Fetch Result: status = \(statusText), error = \(error)")
        }
    }
    
    @IBAction func activateButtonTapped(sender: AnyObject) {
        let result = remoteConfig.activateFetched()
        print("Activate Result: \(result)")
        
        updateValues()
    }
    
    func updateValues() {
        let typeValue = remoteConfig["type"].stringValue ?? ""
        typeLabel.text = typeValue
        
        let levelValue = remoteConfig["level"].numberValue?.integerValue ?? 0
        levelLabel.text = "\(levelValue)"
    }
}
