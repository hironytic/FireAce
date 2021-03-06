//
// CloudMessagingViewController.swift
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
import Firebase

class CloudMessagingViewController: UIViewController {
    @IBOutlet weak var tokenLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let token = FIRInstanceID.instanceID().token() ?? ""
        tokenLabel.text = token
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.tokenRefreshNotification),
                                                         name: kFIRInstanceIDTokenRefreshNotification,
                                                         object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: kFIRInstanceIDTokenRefreshNotification,
                                                            object: nil)
        
        super.viewDidDisappear(animated)
    }

    func tokenRefreshNotification(notification: NSNotification) {
        let token = FIRInstanceID.instanceID().token() ?? ""
        tokenLabel.text = token
    }
    
    @IBAction func tokenLabelTapped(sender: AnyObject) {
        if let token = tokenLabel.text {
            print("Token: \(token)")
        }
    }
    
    @IBAction func subscribeToAppleTapped(sender: AnyObject) {
        FIRMessaging.messaging().subscribeToTopic("/topics/apple")
    }
    
    @IBAction func subsctibeToOrangeTapped(sender: AnyObject) {
        FIRMessaging.messaging().subscribeToTopic("/topics/orange")
    }
    
    @IBAction func subscribeToBananaTapped(sender: AnyObject) {
        FIRMessaging.messaging().subscribeToTopic("/topics/banana")
    }
    
    @IBAction func unsubscribeFromAppleTapped(sender: AnyObject) {
        FIRMessaging.messaging().unsubscribeFromTopic("/topics/apple")
    }
    
    @IBAction func unsubscribeFromOrangeTapped(sender: AnyObject) {
        FIRMessaging.messaging().unsubscribeFromTopic("/topics/orange")
    }
    
    @IBAction func unsubscribeFromBananaTapped(sender: AnyObject) {
        FIRMessaging.messaging().unsubscribeFromTopic("/topics/banana")
    }
}
