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

enum PublicKeyError: Error {
    case emptyFields
    case couldNotCalculate
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var secret: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var publicKey: UILabel!
    @IBOutlet weak var keyImage: UIImageView!
    
    weak var loginDelegate: LoginDelegate?
    weak var loginFailedDelegate: LoginFailedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.keyImage.image = nil
        self.publicKey.text = ""
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
        
        
        
        self.secret.borderStyle = UITextField.BorderStyle.roundedRect
        self.secret.placeholder = "identifier_placeholder".localized()
        self.secret.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center

        self.secret.addTarget(self, action: #selector(fieldEditingChanged), for: UIControl.Event.editingChanged)
        
        self.password.borderStyle = UITextField.BorderStyle.roundedRect
        self.password.placeholder = "password_placeholder".localized()
        self.password.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        
        self.password.addTarget(self, action: #selector(fieldEditingChanged), for: UIControl.Event.editingChanged)
        //sampleTextField.delegate = self
        //self.view.addSubview(self.secret)
        //self.view.addSubview(self.password)

        self.loginButton.setTitle("login_button_label".localized(), for: .normal)
        self.loginButton.layer.cornerRadius = 6
        self.loginButton.addTarget(self, action: #selector(buttonAction), for: UIControl.Event.touchUpInside)
        
        //self.view.addSubview(button)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.secret {
            textField.resignFirstResponder()
            self.password.becomeFirstResponder()
        } else if textField == self.password {
            textField.resignFirstResponder()
            self.buttonAction()
        }
        return true
    }
    
    @objc func fieldEditingChanged(_ sender: Any) {
        do {
            let pk = try self.calculatePublicKey()
            self.publicKey.text = pk
            self.keyImage.image = UIImage(named:"key")
        } catch {
            self.error(message: "could not calculate public key", code: 0)
            self.keyImage.image = nil
            self.publicKey.text = ""
        }
    }
    
    func calculatePublicKey() throws -> String {
        let id: String = self.secret.text!
        let pass: String = self.password.text!
        
        let password: Array<UInt8> = Array(pass.utf8)
        let salt: Array<UInt8> = Array(id.utf8)
        guard let seed = try? Scrypt(password: password, salt: salt, dkLen: 32, N: 4096, r: 16, p: 1).calculate() else {
           throw PublicKeyError.couldNotCalculate
        }
        let sodium = Sodium()
        let k = sodium.sign.keyPair(seed: seed)
        if let key = k {
            let encoded = Base58.base58FromBytes(key.publicKey)
            return encoded
        }
        throw PublicKeyError.couldNotCalculate
    }
    
    @IBAction func buttonAction() {

        // We have the public key, make a request
        guard let pubK = try? self.calculatePublicKey() else {
            return
        }
        
        self.getRequirements(publicKey: pubK)
        // TODO this checks if the user is in the API, but they could be only on the nodes
        // Should we let them in even if the api is not aware ?
        // https://g1.nordstrom.duniter.org/wot/requirements/9itUPU7CVJEHh5DszAYQvgdUvTDLUNkY6NngMfo3F18k
        
    }
    
    func getRequirements(publicKey: String) {
        let url = String(format: "%@/wot/requirements/%@", "default_node".localized(), publicKey)
        
        let request = Request(url: url)
        
        request.jsonDecodeWithCallback(type: IdentityResponse.self, callback: { identityResponse in
            if let identities = identityResponse.identities {
                // TODO think about how to handle multiple identities
                if let ident = identities.first {
                    self.getProfile(publicKey: publicKey, identity: ident)
                }
                
                
            } else {
                // display error message
                self.error(message: "Could not log you in", code: 12)
            }
        })
    }
    
    func getProfile(publicKey: String, identity: Identity) {
        let url = String(format: "%@/user/profile/%@?_source_exclude=avatar._content", "default_data_host".localized(), publicKey)
        
        let request = Request(url: url)
        
        request.jsonDecodeWithCallback(type: ProfileResponse.self, callback: { profileResponse in
            var profile = Profile(issuer: publicKey)
            profile.uid = identity.uid
            profile.signature = identity.sig
            
            DispatchQueue.main.async {
                self.password.text = ""
                self.secret.text = ""
                self.publicKey.text = ""
                self.keyImage.image = nil
            }
            
            if let fullProfile = profileResponse._source {
                //We have the profile data, save and display
                profile = fullProfile
                profile.uid = identity.uid
            }
            
            self.loginDelegate?.login(profile: profile)
        })
    }
    
    func error(message: String, code: Int) {
        if (code == 12) {
            self.loginFailedDelegate?.loginFailed(error: message)
        }
    }
}
