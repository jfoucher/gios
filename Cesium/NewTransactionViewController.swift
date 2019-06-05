//
//  NewTransactionViewController.swift
//  Cesium
//
//  Created by Jonathan Foucher on 01/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation
import UIKit


class NewTransactionViewController: UIViewController, UITextViewDelegate {
    var receiver: Profile?
    var sender: Profile?
    var currency: String?

    @IBOutlet weak var senderAvatar: UIImageView!
    @IBOutlet weak var receiverAvatar: UIImageView!
    @IBOutlet weak var arrow: UIImageView!

    @IBOutlet weak var senderBalance: UILabel!
    @IBOutlet weak var receiverName: UILabel!
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var receiverPubKey: UILabel!
    @IBOutlet weak var senderPubKey: UILabel!
    @IBOutlet weak var close: UILabel!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var comment: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var topBarHeight: NSLayoutConstraint!
    
    weak var loginView: LoginViewController?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            print("found")
            self.topBarHeight.constant = navigationController.navigationBar.frame.height
            self.view.layoutIfNeeded()
        }
        
        self.sendButton.layer.cornerRadius = 6
        
        self.close.text = "close_label".localized()
        //UIApplication.shared.statusBarStyle = .lightContent
        // set arrow to white
        self.arrow.tintColor = .white
        self.arrow.image = UIImage(named: "arrow-right")?.withRenderingMode(.alwaysTemplate)
        
        self.progress.progress = 0.0
        self.amount.addDoneButtonToKeyboard(myAction:  #selector(self.amount.resignFirstResponder))
        self.comment.addDoneButtonToKeyboard(myAction:  #selector(self.comment.resignFirstResponder))
        
        self.comment.text = "comment_placeholder".localized()
        self.comment.textColor = .lightGray
        
        self.receiverAvatar.layer.borderWidth = 1
        self.receiverAvatar.layer.masksToBounds = false
        self.receiverAvatar.layer.borderColor = UIColor.white.cgColor
        self.receiverAvatar.layer.cornerRadius = self.receiverAvatar.frame.width/2
        self.receiverAvatar.clipsToBounds = true
        
        
        if let sender = self.sender, let receiver = self.receiver {
            print(sender.issuer, receiver.issuer)
            if (sender.issuer == receiver.issuer) {
                print("setting to nil")
                self.receiver = nil
                self.receiverAvatar.image = nil
                self.receiverName.text = ""
                //This is us, show the user choice view
                self.changeReceiver(sender: nil)
            }
        }
        
        if let receiver = self.receiver {
            
            
            receiver.getAvatar(imageView: self.receiverAvatar)
            
            self.receiverName.text = receiver.title != nil ? receiver.title : receiver.uid
        }
        
        if let sender = self.sender {
            
            self.senderAvatar.layer.borderWidth = 1
            self.senderAvatar.layer.masksToBounds = false
            self.senderAvatar.layer.borderColor = UIColor.white.cgColor
            self.senderAvatar.layer.cornerRadius = self.receiverAvatar.frame.width/2
            self.senderAvatar.clipsToBounds = true
            
            sender.getAvatar(imageView: self.senderAvatar)
            
            self.senderName.text = sender.title != nil ? sender.title : sender.uid
            let cur = Currency.formattedCurrency(currency: self.currency!)
            if let bal = sender.balance {
                let str = String(format:"%@ %.2f %@", "balance_label".localized(), Double(bal) / 100, cur)
                 self.senderBalance.text = str
            } else {
                sender.getBalance(callback: { total in
                    let str = String(format:"%@ %.2f %@", "balance_label".localized(), Double(total) / 100, cur)
                    self.sender?.balance = total
                    DispatchQueue.main.async {
                        self.senderBalance.text = str
                    }
                })
            }
        }
        

        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        //move view up a bit
        print(UIScreen.main.bounds.height)
        if (UIScreen.main.bounds.height < 700) {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.frame.origin.y -= 100
            })
        }
        if (textView.text == "comment_placeholder".localized() && textView.textColor == .lightGray)
        {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        //move view down
        if (UIScreen.main.bounds.height < 700) {
            UIView.animate(withDuration: 0.2, animations: {
                self.view.frame.origin.y = 0
            })
        }
        if (textView.text == "")
        {
            textView.text = "comment_placeholder".localized()
            textView.textColor = .lightGray
        }
    }
    
    @IBAction func cancel(sender: UIButton) {
        print("cancel")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func send(sender: UIButton?) {
        
        // Set buttons disabled
        
        
        
        
        print("will send")
        guard let receiver = self.receiver else {
            self.changeReceiver(sender: nil)
            return
        }
        
        let title = receiver.title != nil ? receiver.title : receiver.uid
        guard let currency = self.currency else {
            print("no currency")
            return
            
        }
        guard let amstring = self.amount.text else {
            print("no amount")
            return
            
        }
        guard let profile = self.sender else {
            print("no sender")
            return
        }
        
        //Check amount exists
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current

        let am = numberFormatter.number(from: amstring) ?? 0
        
        if (am.floatValue <= 0.0) {
            self.alert(title: "no_amount".localized(), message: "no_amount_message".localized())
            return
        }

        //Check balance
        if let bal = self.sender?.balance {
            if bal < Int(am.floatValue * 100) {
                print(bal, am)
                self.alert(title: "insufficient_funds".localized(), message: "insufficient_funds_message".localized())
                return
            }
        }
        
        //Show login screen if not logged in
        if let sender = self.sender {
            if sender.kp == nil {
                print("no secret key here")
                self.sendButton.isEnabled = true;
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                
                self.loginView = storyBoard.instantiateViewController(withIdentifier: "LoginView") as? LoginViewController
                
                self.loginView?.loginDelegate = self
                //loginView.isModalInPopover = true
                if let v = self.loginView {
                    self.present(v, animated: true, completion: nil)
                }
                
                
                return
            }
        }

        let amountString = String(format: "%.2f %@", Float(truncating: am), Currency.formattedCurrency(currency: currency))
        
        let msg = String(format: "transaction_confirm_message".localized(), amountString, title ?? "")
        let alert = UIAlertController(title: "transaction_confirm_prompt".localized(), message: msg, preferredStyle: .actionSheet)
        print("preparing action")
        alert.addAction(UIAlertAction(title: "transaction_confirm_button_label".localized(), style: .default, handler: {ac in

            self.sendButton.isEnabled = false;
            var text = self.comment?.text ?? ""
            if (self.comment?.text == "comment_placeholder".localized() && self.comment?.textColor == .lightGray)
            {
                text = ""
            }
            
            //TODO validate amount, etc...
            self.progress.progress = 0.1
            self.sender?.getSources(callback: { (error: Error?, resp: SourceResponse?) in
                print("source response", resp)
                if let pk = self.receiver?.issuer, let response = resp {
                    print("issuer", pk)
                    let intAmount = Int(truncating: NSNumber(value: Float(truncating: am) * 100))
                    let url = String(format: "%@/blockchain/current", "default_node".localized())
                    let request = Request(url: url)
                    DispatchQueue.main.async {
                        self.progress.progress = 0.3
                    }
                    request.jsonDecodeWithCallback(type: Block.self, callback: { (err: Error?, block: Block?) in
                        print("block", block)
                        guard let blk = block else {
                            return
                        }
                        DispatchQueue.main.async {
                            self.progress.progress = 0.6
                        }
                        do {
                            let signedTx = try Transactions.createTransaction(response: response, receiverPubKey: pk, amount: intAmount, block: blk, comment: text, profile: profile)
                            DispatchQueue.main.async {
                                self.progress.progress = 0.7
                            }
                            let processUrl = String(format: "%@/tx/process", "default_node".localized())
                            print("processUrl", processUrl)
                            let processRequest = Request(url: processUrl)
                            processRequest.postRaw(rawTx: signedTx, type: Transaction.self, callback: { (error, res) in
                                print(error, res)
                                if let er = error as? RequestError {
                                    print("ERROR")
                                    if let resp = er.responseData {
                                        print("RESPONSE STRING", String(data: resp, encoding: .utf8)!)
                                        if let jsonDict = try! JSONSerialization.jsonObject(with: resp) as? NSDictionary {
                                            print("JSONDICT", jsonDict)
                                            if let msg = jsonDict["message"] as? String {
                                                DispatchQueue.main.async {
                                                    self.errorAlert(message: String(format:"transaction_fail_text".localized(), msg))
                                                }
                                            }
                                        }
                                    }
                                    
                                }
                                if let tx = res {
                                    print("TRANSACTION")
                                    print(tx)
                                    
                                    DispatchQueue.main.async {
                                        self.progress.progress = 1.0
                                        self.cancelButton.isEnabled = true;
                                        self.sendButton.isEnabled = true;
                                        let alert = UIAlertController(title: "transaction_success_title".localized(), message: "transaction_success_message".localized(), preferredStyle: .actionSheet)
                                        
                                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: self.finish))
                                        
                                        self.present(alert, animated: true)
                                    }
                                }
                            })
                            
                        } catch TransactionCreationError.insufficientFunds {
                            self.errorAlert(message: String(format:"transaction_fail_text".localized(), "insuficient funds"))
                            print("insuficient funds")
                        } catch TransactionCreationError.couldNotSignTransaction {
                            print("could not sign transaction")
                            self.errorAlert(message: String(format:"transaction_fail_text".localized(), "could not sign transaction"))
                        } catch {
                            self.errorAlert(message: String(format:"transaction_fail_text".localized(), "unknown error"))
                        }
                        
                        // send transaction
                        
                    })
                    
                }
                
            })
        }))
        
        alert.addAction(UIAlertAction(title: "transaction_cancel_button_label".localized(), style: .cancel, handler: self.finish))
        print("willpresent alert")
        self.present(alert, animated: true)
    }
    
    func finish(action: UIAlertAction) {
        DispatchQueue.main.async {
            self.cancelButton.isEnabled = true
            self.sendButton.isEnabled = true
            self.progress.progress = 0.0
        }
    }
    
    func errorAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "transaction_fail_title".localized(), message: message, preferredStyle: .actionSheet)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: self.finish))

            self.present(alert, animated: true)
            self.cancelButton.isEnabled = true;
            self.sendButton.isEnabled = true;
        
            self.progress.progress = 1.0
        }
    }

    
    func alert(title: String, message: String?) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: self.finish))
            
            self.present(alert, animated: true)
        }
    }
    
    @IBAction func changeReceiver(sender: UIButton?) {
        DispatchQueue.main.async {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let changeUserView = storyBoard.instantiateViewController(withIdentifier: "ChangeUserView") as! ChangeReceiverViewController
            
            changeUserView.isModalInPopover = true
            changeUserView.profileSelectedDelegate = self

            self.present(changeUserView, animated: true, completion: nil)
        }
    }
}

protocol ReceiverChangedDelegate: class {
    func receiverChanged(receiver: Profile)
}

extension NewTransactionViewController: ReceiverChangedDelegate {
    func receiverChanged(receiver: Profile) {
        self.receiver = receiver
        self.receiver?.getAvatar(imageView: self.receiverAvatar)
        self.receiverName.text = receiver.title != nil ? receiver.title : receiver.uid
        print("new receiver")
    }
}

extension NewTransactionViewController: LoginDelegate {
    func login(profile: Profile) {
        self.sender = profile
        print("in login delegate")
        DispatchQueue.main.async {
            
            if let v = self.loginView {
                v.dismiss(animated: true, completion: {
                    DispatchQueue.main.async {
                        self.send(sender: nil)
                    }
                })
            }
            
        }
        
    }
}
