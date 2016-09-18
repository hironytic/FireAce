//
// AuthenticationViewController.swift
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
import FirebaseAuth
import FirebaseAuthUI

class AuthenticationViewController: UIViewController {
    @IBOutlet weak var nameItemLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailItemLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    
    @IBOutlet weak var signInButton: UIButton!

    private let auth = FIRAuth.auth()
    private var authStateDidChangeListenerHandle: FIRAuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameItemLabel.hidden = true
        nameLabel.hidden = true
        nameLabel.text = ""
        emailItemLabel.hidden = true
        emailLabel.hidden = true
        emailLabel.text = ""
        signOutButton.hidden = true
        signInButton.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        authStateDidChangeListenerHandle = auth?.addAuthStateDidChangeListener({ (auth, user) in
            if let user = user {
                self.nameItemLabel.hidden = false
                self.nameLabel.hidden = false
                self.nameLabel.text = user.displayName
                self.emailItemLabel.hidden = false
                self.emailLabel.hidden = false
                self.emailLabel.text = user.email
                self.signOutButton.hidden = false
                self.signInButton.hidden = true
            } else {
                self.nameItemLabel.hidden = true
                self.nameLabel.hidden = true
                self.emailItemLabel.hidden = true
                self.emailLabel.hidden = true
                self.signOutButton.hidden = true
                self.signInButton.hidden = false
            }
        })
    }
    
    override func viewDidDisappear(animated: Bool) {
        if let handle = authStateDidChangeListenerHandle {
            auth?.removeAuthStateDidChangeListener(handle)
        }
        
        super.viewDidDisappear(animated)
    }
    
    @IBAction func signInButtonTapped(sender: AnyObject) {
        guard let authUI = FIRAuthUI.defaultAuthUI() else { return }
        let authViewController = authUI.authViewController()
        presentViewController(authViewController, animated: true, completion: nil)
    }
    
    @IBAction func signOutButtonTapped(sender: AnyObject) {
        do {
            try auth?.signOut()
        } catch let error {
            print("Error : \(error)")
        }
    }
}
