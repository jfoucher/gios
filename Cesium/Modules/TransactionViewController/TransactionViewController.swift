//
//  TransactionViewController.swift
//  Cesium
//
//  Created by Jonathan Foucher on 01/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation
import Sodium
import UIKit

class TransactionViewController: UIViewController {

    @IBOutlet private weak var closeButtonView: CloseButton?
    @IBOutlet weak private var dateLabel: UILabel?
    @IBOutlet weak private var senderAvatarImageView: UIImageView?
    @IBOutlet weak private var senderNameLabel: UILabel?
    @IBOutlet weak private var arrowImageView: UIImageView?
    @IBOutlet weak private var amountLabel: UILabel?
    @IBOutlet weak private var receiverAvatarImageView: UIImageView?
    @IBOutlet weak private var receiverNameLabel: UILabel?
    @IBOutlet weak private var txHashLabel: UILabel?
    @IBOutlet weak private var commentTextView: UITextView?
    @IBOutlet weak private var decryptCommentButton: UIButton?
    
    weak var loginDelegate: LoginDelegate?
    var transaction: ParsedTransaction?
    var currency: String = "g1"
    var loginView: LoginViewController?
    
    var sender: Profile? {
        didSet {
            print("got sender")
            DispatchQueue.main.async {
                guard let avatar = self.senderAvatarImageView else {
                    return
                }
                self.sender?.getAvatar(imageView: avatar)
                self.senderNameLabel?.text = self.sender?.getName()
                self.decodeComment()
            }
        }
    }
    
    var receiver: Profile? {
        didSet {
            print("got receiver")
            DispatchQueue.main.async {
                guard let avatar = self.receiverAvatarImageView else {
                    return
                }
                self.receiver?.getAvatar(imageView: avatar)
                self.receiverNameLabel?.text = self.receiver?.getName()
                self.decodeComment()
            }
        }
    }
    
    // ------------------------
    // MARK: Lyfe Cycle Methods
    // ------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let senderAvatarWidth = self.senderAvatarImageView?.frame.width,
            let receivreAvatarWidth = self.receiverAvatarImageView?.frame.width else {
            return
        }
        self.senderAvatarImageView?.layer.cornerRadius = senderAvatarWidth / 2
        self.receiverAvatarImageView?.layer.cornerRadius = receivreAvatarWidth / 2
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.commentTextView?.setContentOffset(.zero, animated: false)
//        self.senderAvatar.layer.cornerRadius = self.senderAvatar.frame.width/2
//        self.receiverAvatar.layer.cornerRadius = self.receiverAvatar.frame.width/2
    }
}

// ------------------------
// MARK: IBActions
// ------------------------

extension TransactionViewController {
    @IBAction func decryptComment(_ sender: Any) {
        print("decryptComment")
        let storyBoard : UIStoryboard = UIStoryboard(name: "LoginViewController", bundle: nil)
        
        self.loginView = storyBoard.instantiateViewController(withIdentifier: "LoginView") as? LoginViewController
        
        self.loginView?.loginDelegate = self
        self.loginView?.sendingTransaction = true
        //loginView.isModalInPopover = true
        if let v = self.loginView {
            self.present(v, animated: true, completion: nil)
        }
    }
}

// ------------------------
// MARK: LoginDelegate
// ------------------------

extension TransactionViewController: LoginDelegate {
    func login(profile: Profile) {
        self.receiver = profile
        print("in login delegate")
        DispatchQueue.main.async {
            if let ld = self.loginDelegate {
                ld.login(profile: profile)
            }
            
            self.decryptCommentButton?.isHidden = true
            self.decodeComment()
            if let v = self.loginView {
                v.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// ------------------------
// MARK: Convenience Methods
// ------------------------

extension TransactionViewController {
    // InitView allow to set all the design
    private func initView() {
        self.closeButtonView?.closeClosure = { 
            self.dismiss(animated: true, completion: nil)
        }
        
        self.senderAvatarImageView?.layer.borderWidth = 1
        self.senderAvatarImageView?.layer.masksToBounds = false
        self.senderAvatarImageView?.layer.borderColor = UIColor.white.cgColor
        self.senderAvatarImageView?.clipsToBounds = true
        
        self.receiverAvatarImageView?.layer.borderWidth = 1
        self.receiverAvatarImageView?.layer.masksToBounds = false
        self.receiverAvatarImageView?.layer.borderColor = UIColor.white.cgColor
        self.receiverAvatarImageView?.clipsToBounds = true
        
        self.txHashLabel?.text = self.transaction?.hash
        
        //        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
        //            print("found")
        //            self.topBarHeight.constant = navigationController.navigationBar.frame.height
        //            self.view.layoutIfNeeded()
        //        }
        
        // Set arrow to white
        // I create UIImage+Extensions class, convenience method to change color :)
        // You can remove this comment after reeading this :)
        self.arrowImageView?.with(color: .white)
        
        self.fillData()
    }
    
    // This method is used to separate design from data
    private func fillData() {
        if let am = self.transaction?.amount {
            let currency = Currency.formattedCurrency(currency: self.currency)
            var a = Double(truncating: am as NSNumber)
            if (a < 0) {
                a *= -1
            }
            self.amountLabel?.text = String(format: "%.2f %@", a / 100, currency)
        }
        
        
        if let tx = self.transaction {
            let date = Date(timeIntervalSince1970: Double(tx.time))
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd MMMM YYYY"
            let d = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "HH:mm:ss"
            let t = dateFormatter.string(from: date)
            self.dateLabel?.text = String(format: "transaction_view_date_format".localized(), d, t)
            
            if (tx.comment.isEmpty) {
                self.commentTextView?.text = "no_comment_placeholder".localized()
                self.commentTextView?.textColor = .lightGray
            } else {
                self.commentTextView?.text = tx.comment
                
            }
            print(tx.pubKey)
            self.getSender(pubKey: tx.pubKey)
            
            if ((tx.to.count > 0 && self.receiver == nil) || (tx.amount < 0 && self.receiver?.kp == nil)) {
                self.getReceiver(pubKey: tx.to[0])
            }
            
            if (tx.comment.starts(with: "enc ")) {
                // Display decrypt comment button
                if let receiver = self.receiver {
                    self.decryptCommentButton?.setTitle("decrypt_comment_button_label".localized(), for: .normal)
                    if (receiver.kp != nil || receiver.issuer != tx.to[0]) {
                        self.decryptCommentButton?.isHidden = true
                    }
                }
            } else {
                self.decryptCommentButton?.isHidden = true
            }
        }
    }
    
    func decodeComment() {
        print("decoding comment")
        if let tx = self.transaction {
            print("tx exists")
            if (tx.comment.starts(with: "enc ")) {
                print("comment starts with enc")
                if let seed = self.receiver?.kp, let senderPublicKey = self.sender?.issuer {
                    print("pk and seed exist")
                    let sodium = Sodium()
                    print("seed", seed)
                    print("senderPublicKey", senderPublicKey)
                    let kp = sodium.sign.keyPair(seed: Base58.bytesFromBase58(seed))!
                    
                    let conv = sodium.sign.convertEd25519KeyPairToCurve25519(keyPair: kp)!
                    let senderPK = sodium.sign.convertEd25519PkToCurve25519(publicKey: Base58.bytesFromBase58(senderPublicKey))!
                    
                    let cipherText = String(tx.comment.dropFirst(4))
                    print("decrypting from converted public key", Base58.base58FromBytes(senderPK))
                    print("decrypting to converted private key", Base58.base58FromBytes(conv.secretKey))
                    let d = sodium.box.open(nonceAndAuthenticatedCipherText: Array(cipherText.utf8),
                                            senderPublicKey: senderPK,
                                            recipientSecretKey: conv.secretKey)
                    print("decrypted", d)
                    if let decrypted: Bytes =
                        sodium.box.open(nonceAndAuthenticatedCipherText: Base58.bytesFromBase58(cipherText),
                                        senderPublicKey: senderPK,
                                        recipientSecretKey: conv.secretKey) {
                        self.commentTextView?.text = String(bytes: decrypted, encoding: .utf8)
                    }
                }
            }
        }
    }
    
    func getSender(pubKey: String) {
        print("getting sender for " + pubKey)
        Profile.getRequirements(publicKey: pubKey, callback: { identity in
            // Force getting profile from public key
            var ident = identity
            if (identity == nil) {
                ident = Identity(pubkey: pubKey, uid: "")
            }
            Profile.getProfile(publicKey: pubKey, identity: ident, callback: { profile in
                if let prof = profile, let am = self.transaction?.amount {
                    //Reverse display if amount is negative
                    print("got profile, amount is", am)
                    if (am < 0) {
                        self.receiver = prof
                    } else {
                        self.sender = prof
                    }
                } else {
                    print("no profile for " + pubKey)
                }
            })
        })
    }
    
    func getReceiver(pubKey: String) {
        print("getting receiver for " + pubKey)
        Profile.getRequirements(publicKey: pubKey, callback: { identity in
            // Force getting profile from public key
            var ident = identity
            if (identity == nil) {
                ident = Identity(pubkey: pubKey, uid: "")
            }
            Profile.getProfile(publicKey: pubKey, identity: ident, callback: { profile in
                if let prof = profile, let am = self.transaction?.amount {
                    if (am < 0) {
                        self.sender = prof
                    } else {
                        self.receiver = prof
                    }
                } else {
                    print("no profile for " + pubKey)
                }
            })
        })
    }
}
