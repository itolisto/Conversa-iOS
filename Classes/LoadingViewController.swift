//
//  LoadingViewController.swift
//  Conversa
//
//  Created by Edgar Gomez on 10/1/18.
//  Copyright © 2018 Conversa. All rights reserved.
//

import UIKit

import Firebase
import FirebaseAuth

class LoadingViewController: UIViewController {

    override func viewDidLoad() {
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { (token, error) in
            if let error = error {
                return
            }

            SettingsKeys.setCustomerTokenStatus(false)
            SettingsKeys.setCustomerToken(token)
        })
    }

}
