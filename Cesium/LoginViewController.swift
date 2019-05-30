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
    
    var secret: UITextField = UITextField(frame: CGRect(x: 30, y: 300, width: UIScreen.main.bounds.width - 60, height: 40))
    
    var password: UITextField = UITextField(frame: CGRect(x: 30, y: 380, width: UIScreen.main.bounds.width - 60, height: 40))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        let image = UIImage(named: "logo")
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: 0, y: 60, width: 200, height: 200)
        imageView.center.x = self.view.center.x
        imageView.tag = 100
        self.view.addSubview(imageView)
        
        self.secret.font = UIFont.systemFont(ofSize: 15)
        self.secret.borderStyle = UITextField.BorderStyle.roundedRect
        self.secret.autocorrectionType = UITextAutocorrectionType.no
        self.secret.keyboardType = UIKeyboardType.default
        self.secret.placeholder = "identifier_placeholder".localized()
        self.secret.returnKeyType = UIReturnKeyType.done
        self.secret.clearButtonMode = UITextField.ViewMode.whileEditing
        self.secret.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        self.secret.isSecureTextEntry = true
        self.secret.tag = 100
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
        self.view.addSubview(self.secret)
        self.view.addSubview(self.password)
        
        let button = UIButton(type: UIButton.ButtonType.system)
        button.frame = CGRect(x: 30, y: UIScreen.main.bounds.height - 180, width:UIScreen.main.bounds.width - 60, height: 60)
        button.tag = 100
        button.setTitle("login_button_label".localized(), for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.layer.cornerRadius = 6
        
        self.view.addSubview(button)
    }
    
    @IBAction func onReturn() {
        self.password.resignFirstResponder()
        // do whatever you want...
        print("enter")
        self.buttonAction(sender: nil)
    }
    
    @objc func buttonAction(sender: UIButton?) {
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
                            print(profile)
                            DispatchQueue.main.async { // Make sure you're on the main thread here
                                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                let profileViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileView") as! ProfileViewController
                                profileViewController.profile = profile
                                self.navigationController?.pushViewController(profileViewController, animated: true)
                            }
                            
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
}
