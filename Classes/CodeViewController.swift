//
//  CodeViewController.swift
//  Conversa
//
//  Created by Edgar Gomez on 9/14/17.
//  Copyright © 2017 Conversa. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class CodeViewController: UIViewController {

    @IBOutlet weak var btnValidate: UIStateButton!
    @IBOutlet weak var btnGetCode: UIStateButton!
    @IBOutlet weak var lblInfo: TTTAttributedLabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.btnValidate.setBackgroundColor(Colors.green(), for: .normal)
        self.btnValidate.setTitleColor(Colors.white(), for: .normal)
        self.btnValidate.setBackgroundColor(UIColor.clear, for: .highlighted)
        self.btnValidate.setTitleColor(Colors.green(), for: .highlighted)

        self.btnGetCode.setBackgroundColor(UIColor.clear, for: .normal)
        self.btnGetCode.setTitleColor(Colors.green(), for: .normal)
        self.btnGetCode.setBackgroundColor(Colors.green(), for: .highlighted)
        self.btnGetCode.setTitleColor(UIColor.white, for: .highlighted)

        let attrStr = NSMutableAttributedString.init(string: self.lblInfo.text!, attributes: nil)

        let size = self.lblInfo.text?.characters.count
        let start = NSMakeRange(0, size! - 8)
        let end = NSMakeRange(size! - 8, 8)

        // Normal
        let attributesNormal: [String: Any] = [NSForegroundColorAttributeName: UIColor.lightGray]
        attrStr.setAttributes(attributesNormal, range: start)
        // Green
        //[UIColor colorWithRed:6.0f/255.0f green:242.0f/255.0f blue:143.0f/255.0f alpha:1.0]
        let attributesGreen: [String: Any] = [NSForegroundColorAttributeName: UIColor.green]
        attrStr.setAttributes(attributesGreen, range: end)
        // Active
        let attributesActive: [String: Any] = [NSForegroundColorAttributeName: UIColor.lightGray]
        self.lblInfo.activeLinkAttributes = attributesActive

        //let url = NSURL.fileURL(withPath: "https://conversa.typeform.com/to/RRg54U")
        let url = NSURL(string: "https://conversachat.com")! as URL
        
        self.lblInfo.addLink(to: url, with: end)
        self.lblInfo.attributedText = attrStr;
        self.lblInfo.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue //NSTextCheckingTypeLink;
        self.lblInfo.delegate = self;
    }

}

extension CodeViewController : TTTAttributedLabelDelegate {

    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        // Present view controller
        let storyboard = UIStoryboard.init(name: "Login", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")

//        let aObjNavi = UINavigationController(rootViewController: vc)
//        self.present(aObjNavi, animated: true, completion: nil)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
