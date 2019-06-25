//
//  CesiumTests.swift
//  CesiumTests
//
//  Created by Jonathan Foucher on 30/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import XCTest
import Sodium
import CryptoSwift

import Clibsodium
@testable import Cesium

extension Sign {
    /**
     Converts an Ed25519 public key used for signing into a Curve25519 public key usable for encryption.
     
     - Parameter publicKey: an Ed25519 public key generated from Sign.keyPair()
     
     - Returns: A Box.PublicKey is conversion succeeds, nil otherwise
     */
    public func convertEd25519PkToCurve25519(publicKey: PublicKey) -> Box.PublicKey? {
        var curve25519Bytes = Array<UInt8>(repeating: 0, count: crypto_box_publickeybytes())
        if 0 == crypto_sign_ed25519_pk_to_curve25519(&curve25519Bytes, publicKey) {
            return Box.PublicKey(curve25519Bytes)
        } else {
            return nil
        }
    }
    
    /**
     Converts an Ed25519 secret key used for signing into a Curve25519 keypair usable for encryption.
     
     - Parameter publicKey: an Ed25519 secret key generated from Sign.keyPair()
     
     - Returns: A Box.SecretKey is conversion succeeds, nil otherwise
     */
    public func convertEd25519SkToCurve25519(secretKey: SecretKey) -> Box.SecretKey? {
        var curve25519Bytes = [UInt8](repeating: 0, count: crypto_box_secretkeybytes())
        if 0 == crypto_sign_ed25519_sk_to_curve25519(&curve25519Bytes, secretKey) {
            return Box.SecretKey(curve25519Bytes)
        }
        else {
            return nil
        }
    }
    
    /**
     Converts an Ed25519 Sign.KeyPair into a Curve25519 Box.KeyPair.  This is a convenience method
     for calling convertEd25519PkToCurve25519 and convertEd25519SkToCurve25519 individually.
     
     - Parameter keyPair: A Sign.KeyPair generated from Sign.KeyPair()
     
     - Returns: a Box.KeyPair, nil if either key conversion fails
     */
    public func convertEd25519KeyPairToCurve25519(keyPair: KeyPair) -> Box.KeyPair? {
        let publicKeyResult = convertEd25519PkToCurve25519(publicKey: keyPair.publicKey)
        let secretKeyResult = convertEd25519SkToCurve25519(secretKey: keyPair.secretKey)
        
        if let publicKey = publicKeyResult, let secretKey = secretKeyResult {
            return Box.KeyPair(publicKey: publicKey, secretKey: secretKey)
        }
        else {
            return nil;
        }
    }
}

class CesiumTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testKetGeneration() {
        let sodium = Sodium()
        
        let boxKeyPair = sodium.box.keyPair(seed: Array("blabla".utf8))!
        print("box public", Base58.base58FromBytes(boxKeyPair.publicKey))
        
        let signKeyPair = sodium.sign.keyPair(seed: Array("blabla".utf8))!
        print("sign public", Base58.base58FromBytes(signKeyPair.publicKey))
    }

    func testMessageEncryption() {
        let sodium = Sodium()
        
        let salt: Array<UInt8> = Array("testes".utf8)
        let password: Array<UInt8> = Array("ghgh".utf8)
        
        guard let seed = try? Scrypt(password: password, salt: salt, dkLen: 32, N: 4096, r: 16, p: 1).calculate() else {
            print("error")
            return
        }
        
        let salt2: Array<UInt8> = Array("ersr".utf8)
        let password2: Array<UInt8> = Array("seresr".utf8)
        
        guard let seed2 = try? Scrypt(password: password2, salt: salt2, dkLen: 32, N: 4096, r: 16, p: 1).calculate() else {
            print("error")
            return
        }
//
        let aliceKeyPair = sodium.sign.keyPair(seed: seed)!
        let bobKeyPair = sodium.sign.keyPair(seed: seed2)!

        let conv = sodium.sign.convertEd25519KeyPairToCurve25519(keyPair: aliceKeyPair)!
        let recipientPublicKey = sodium.sign.convertEd25519PkToCurve25519(publicKey: bobKeyPair.publicKey)!
        
        let message = Array("My Test Message".utf8)
        
        let encryptedMessageFromAliceToBob: Bytes = sodium.box.seal(message: message, recipientPublicKey: recipientPublicKey, senderSecretKey: conv.secretKey)!

        let encoded = "enc " + Base58.base58FromBytes(encryptedMessageFromAliceToBob)
        

        let cipherText = String(encoded.dropFirst(4))
        
        let boxKeyPair = sodium.sign.convertEd25519KeyPairToCurve25519(keyPair: bobKeyPair)!
        let senderPublicKey = sodium.sign.convertEd25519PkToCurve25519(publicKey: aliceKeyPair.publicKey)!
        
        let messageVerifiedAndDecryptedByBob =
            sodium.box.open(nonceAndAuthenticatedCipherText: Base58.bytesFromBase58(cipherText),
                            senderPublicKey: senderPublicKey,
                            recipientSecretKey: boxKeyPair.secretKey)!
        print(String(bytes: messageVerifiedAndDecryptedByBob, encoding: .utf8))
        XCTAssert(String(bytes: messageVerifiedAndDecryptedByBob, encoding: .utf8)! == "My Test Message")
        

        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
