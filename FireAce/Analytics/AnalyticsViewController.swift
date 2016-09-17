//
// AnalyticsViewController.swift
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

class AnalyticsViewController: UIViewController {
    @IBOutlet weak var favIceCream: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        favIceCream.selectedSegmentIndex = UISegmentedControlNoSegment
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    

    @IBAction func dogButtonTapped(sender: AnyObject) {
        eventButtonTapped(value: "dog", message: "🐶")
    }
    
    @IBAction func catButtonTapped(sender: AnyObject) {
        eventButtonTapped(value: "cat", message: "🐱")
    }

    private func eventButtonTapped(value value: String, message: String) {
        FIRAnalytics.logEventWithName("ace_event", parameters: [
            "value": value,
        ])
        
        let alertController = UIAlertController(title: message, message: "", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func favIceCreamChanged(sender: AnyObject) {
        if let value = favIceCream.titleForSegmentAtIndex(favIceCream.selectedSegmentIndex) {
            FIRAnalytics.setUserPropertyString(value, forName: "fav_ice_cream")
        }
    }
}
