//
//  Sign.swift
//  Cesium
//
//  Created by Jonathan Foucher on 24/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation
import Sodium
import Clibsodium

extension Sign {
    /**
     Converts an Ed25519 public key used for signing into a Curve25519 public key usable for encryption.
     
     - Parameter publicKey: an Ed25519 public key generated from Sign.keyPair()
     
     - Returns: A Box.PublicKey is conversion succeeds, nil otherwise
     */
    public func convertEd25519PkToCurve25519(publicKey: PublicKey) -> Box.PublicKey? {
        var curve25519Bytes = [UInt8](repeating: 0, count: crypto_box_publickeybytes())
        
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
