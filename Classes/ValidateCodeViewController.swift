//
//  ValidateCodeViewController.swift
//  Conversa
//
//  Created by Edgar Gomez on 9/14/17.
//  Copyright © 2017 Conversa. All rights reserved.
//

import UIKit
import MBProgressHUD
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
        self.btnValidate.setBackgroundColor(UIColor.groupTableViewBackground, for: .disabled)
        self.btnValidate.setTitleColor(UIColor.darkGray, for: .disabled)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
            self.pinCodeTextField.becomeFirstResponder()
        }

        pinCodeTextField.delegate = self
        pinCodeTextField.keyboardType = .numberPad
    }

    @IBAction func validateButtonPressed(_ sender: UIStateButton) {
        let hudError : MBProgressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        hudError.mode = MBProgressHUDMode.indeterminate;
        hudError.button.removeTarget(nil, action: nil, for: .allEvents)
        // TODO: Replace with networking layer
//        PFCloud.callFunction(inBackground: "validateConversaCode",
//                             withParameters: ["code": pinCodeTextField.text ?? ""])
//        { (success: Any?, error: Error?) in
//            hudError.hide(animated: true)
//            if error != nil {
//                self.showCodeError()
//            } else {
//                var dic : [String:Int]? = nil
//                if let data = (success as! String).data(using: .utf8) {
//                    do {
//                        dic = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Int]
//                    } catch {
//                        print(error.localizedDescription)
//                    }
//                }
//
//                if dic == nil || dic!["valid"] == 0 {
//                    self.showCodeError()
//                } else {
//                    _ = SweetAlert().showAlert(
//                        NSLocalizedString("vcvc_alert_success_title", comment: "Validate code success title"),
//                        subTitle: NSLocalizedString("vcvc_alert_success_subtitle", comment: "Validate code success subtitle"),
//                        style: .success,
//                        buttonTitle: NSLocalizedString("vcvc_alert_success_button", comment: "Validate code success button"),
//                        action: { (result) in
//                            if result == true {
//                                // Save code is already valid
//                                SettingsKeys.setCodeValidatedSetting(true)
//                                // Present view controller
//                                let storyboard = UIStoryboard.init(name: "Login", bundle: nil)
//                                let vc = storyboard.instantiateViewController(withIdentifier: "LoginView")
//                                self.present(vc, animated: true, completion: nil)
//                            }
//                    })
//                }
//            }
//        }
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    func showCodeError() {
        _ = SweetAlert().showAlert(
            "Oops",
            subTitle: NSLocalizedString("vcvc_alert_subtitle", comment: "Validate code error validation"),
            style: .error,
            buttonTitle: NSLocalizedString("vcvc_alert_subtitle_button", comment: "Validate code error validation button"),
            buttonColor: Colors.red(),
            action: { (result) in
                if result == true {
                    let storyboard = UIStoryboard.init(name: "Code", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "GetCodeViewController")
                    self.navigationController?.pushViewController(vc, animated: true)
                }
        })
    }
}

extension ValidateCodeViewController : PinCodeTextFieldDelegate {

    func textFieldValueChanged(_ textField: PinCodeTextField) {
        if ((textField.text?.count)! < 6) {
            self.btnValidate.isEnabled = false
        } else {
            self.btnValidate.isEnabled = true
        }
    }

    func textFieldDidEndEditing(_ textField: PinCodeTextField) {
        // called when pinCodeTextField did end editing
        self.btnValidate.isEnabled = true
    }

    func textFieldShouldReturn(_ textField: PinCodeTextField) -> Bool {
        // called when 'return' key pressed. return false to ignore.
        return true
    }

}
