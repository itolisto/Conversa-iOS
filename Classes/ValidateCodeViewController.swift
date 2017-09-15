//
//  ValidateCodeViewController.swift
//  Conversa
//
//  Created by Edgar Gomez on 9/14/17.
//  Copyright © 2017 Conversa. All rights reserved.
//

import UIKit
import PinCodeTextField

class ValidateCodeViewController: UIViewController {

    @IBOutlet weak var btnValidate: UIStateButton!
    @IBOutlet weak var pinCodeTextField: PinCodeTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.btnValidate.setBackgroundColor(UIColor.clear, for: .normal)
        self.btnValidate.setTitleColor(Colors.green(), for: .normal)
        self.btnValidate.setBackgroundColor(Colors.green(), for: .highlighted)
        self.btnValidate.setTitleColor(UIColor.white, for: .highlighted)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            self.pinCodeTextField.becomeFirstResponder()
        }
        
        pinCodeTextField.delegate = self
        pinCodeTextField.keyboardType = .numberPad
    }

    @IBAction func validateButtonPressed(_ sender: UIStateButton) {
        PFCloud.callFunction(inBackground: "validateConversaCode",
                             withParameters: ["code": "123456"])
        { (success: Any?, error: Error?) in
            if error != nil {
                SweetAlert().showAlert(
                    "fasdfdas",
                    subTitle: "fdsdsa",
                    style: .error,
                    buttonTitle: "fadsfad",
                    action: nil)
            } else {
                SweetAlert().showAlert(
                    "fasdfdas",
                    subTitle: "fdsdsa",
                    style: .success,
                    buttonTitle: "fadsfad"
                ) { (result) in
                    if result == true {
                        let storyboard = UIStoryboard.init(name: "Login", bundle: nil)
                        let vc = storyboard.instantiateViewController(withIdentifier: "LoginView")
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension ValidateCodeViewController: PinCodeTextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }

    func textFieldDidBeginEditing(_ textField: PinCodeTextField) {

    }

    func textFieldValueChanged(_ textField: PinCodeTextField) {
        print("value changed: \(String(describing: textField.text))")
    }

    func textFieldShouldEndEditing(_ textField: PinCodeTextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: PinCodeTextField) -> Bool {
        return true
    }

}
