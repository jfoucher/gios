//
//  LoginViewController.swift
//  Cesium
//
//  Created by Jonathan Foucher on 30/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation
import UIKit
import Sodium
import CryptoSwift



class LoginViewController: UIViewController {
    
    @IBOutlet weak var secret: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    weak var delegate: LoginDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 /*&& UIScreen.main.bounds.height - 420 < keyboardSize.height*/ {
                var val = CGFloat(100.0)
                if let frame = self.loginButton?.frame {
                    val = CGFloat(UIScreen.main.bounds.height - frame.origin.y) - frame.height - 10
                }
                self.view.frame.origin.y -= CGFloat(keyboardSize.height) - val
                
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        let image = UIImage(named: "logo")
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: 0, y: 100, width: 150, height: 150)
        imageView.center.x = self.view.center.x
        //self.view.addSubview(imageView)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "logout_button_label".localized(), style: .plain, target: nil, action: nil)
        self.secret.font = UIFont.systemFont(ofSize: 15)
        self.secret.borderStyle = UITextField.BorderStyle.roundedRect
        self.secret.autocorrectionType = UITextAutocorrectionType.no
        self.secret.keyboardType = UIKeyboardType.default
        self.secret.placeholder = "identifier_placeholder".localized()
        self.secret.returnKeyType = UIReturnKeyType.done
        self.secret.clearButtonMode = UITextField.ViewMode.whileEditing
        self.secret.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        self.secret.isSecureTextEntry = true

        self.secret.addTarget(self, action: #selector(onReturn), for: UIControl.Event.editingDidEndOnExit)
        
        self.password.font = UIFont.systemFont(ofSize: 15)
        self.password.borderStyle = UITextField.BorderStyle.roundedRect
        self.password.autocorrectionType = UITextAutocorrectionType.no
        self.password.keyboardType = UIKeyboardType.default
        self.password.placeholder = "password_placeholder".localized()
        self.password.returnKeyType = UIReturnKeyType.go
        self.password.clearButtonMode = UITextField.ViewMode.whileEditing
        self.password.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        self.password.isSecureTextEntry = true
        self.password.addTarget(self, action: #selector(onReturn), for: UIControl.Event.editingDidEndOnExit)
        //sampleTextField.delegate = self
        //self.view.addSubview(self.secret)
        //self.view.addSubview(self.password)

        self.loginButton.setTitle("login_button_label".localized(), for: .normal)
        self.loginButton.layer.cornerRadius = 6
        
        //self.view.addSubview(button)
    }
    
    @IBAction func onReturn() {
        self.password.resignFirstResponder()
        // do whatever you want...
        print("enter")
        self.buttonAction(sender: nil)
    }
    
    @IBAction func buttonAction(sender: UIButton?) {
        let id: String = self.secret.text!
        let pass: String = self.password.text!
        
        let password: Array<UInt8> = Array(pass.utf8)
        let salt: Array<UInt8> = Array(id.utf8)
        
        do {
            let seed = try Scrypt(password: password, salt: salt, dkLen: 32, N: 4096, r: 16, p: 1).calculate()
            let sodium = Sodium()
            let k = sodium.sign.keyPair(seed: seed)
            if let key = k {
                let encoded = Base58.base58FromBytes(key.publicKey)
                print("Encoded string: \(encoded)")
                
                // We have the public key, make a request
                
                let url = URL(string: String(format: "%@/user/profile/%@?_source_exclude=avatar._content", "default_data_host".localized(), encoded))!
                
                let session = URLSession.shared
                let task = session.dataTask(with: url, completionHandler: { data, response, error in
                    if let type = response?.mimeType {
                        guard type == "application/json" else {
                            print("Wrong MIME type!")
                            return
                        }
                    }
                    guard let responseData = data else {
                        print("NO DATA")
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    do {
                        let profileResponse = try decoder.decode(ProfileResponse.self, from: responseData)
                        //We have the profile data, save and display
                        if let profile = profileResponse._source {
                            //We have the profile data, save and display
                            print("in loginView")
                            DispatchQueue.main.async {
                                self.password.text = ""
                                self.secret.text = ""
                            }
                            
                            self.delegate?.login(profile: profile)
                            
                        } else {
                            // display error message
                            print("Could not log you in")
                        }
                    } catch {
                        print("error trying to convert data to JSON")
                        print(error)
                    }
                })
                
                task.resume()
                //https://g1.data.duniter.fr/user/profile/EEdwxSkAuWyHuYMt4eX5V81srJWVy7kUaEkft3CWLEiq?&_source_exclude=avatar._content
                
            }
            
        } catch {
            print("error")
        }
        
    }
    
    func error() {
        
    }
}
