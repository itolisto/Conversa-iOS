//
//  CodeViewController.swift
//  Conversa
//
//  Created by Edgar Gomez on 9/14/17.
//  Copyright © 2017 Conversa. All rights reserved.
//

import UIKit
import SafariServices
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

        let str = NSLocale.preferredLanguages[0]
        let index = str.index(str.startIndex, offsetBy: 2)

        let language = str.substring(to: index)
        let size = self.lblInfo.text?.characters.count
        var start, end : NSRange;

        if (language == "es") {
            start = NSMakeRange(0, size! - 13);
            end = NSMakeRange(size! - 13, 13);
        } else {
            start = NSMakeRange(0, size! - 8);
            end = NSMakeRange(size! - 8, 8);
        }

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
        let url = NSURL(string: "https://conversa.typeform.com/to/RRg54U")! as URL
        
        self.lblInfo.addLink(to: url, with: end)
        self.lblInfo.attributedText = attrStr;
        self.lblInfo.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue //NSTextCheckingTypeLink;
        self.lblInfo.delegate = self;
    }

}

extension CodeViewController : TTTAttributedLabelDelegate {

    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let svc = SFSafariViewController.init(url: url, entersReaderIfAvailable: false)
        svc.delegate = self;

//        if #available(iOS 10.0, *) {
//            // The color to tint the background of the navigation bar and the toolbar.
//            svc.preferredBarTintColor = readerMode ? .blue : .orange
//            // The color to tint the the control buttons on the navigation bar and the toolbar.
//            svc.preferredControlTintColor = .white
//        } else {
//            // Fallback on earlier versions
//        }

        self.present(svc, animated: true, completion: nil)
    }

}

extension CodeViewController: SFSafariViewControllerDelegate {

    func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        //Tells the delegate that the initial URL load completed.
    }

    func safariViewController(_ controller: SFSafariViewController, activityItemsFor URL: URL, title: String?) -> [UIActivity] {
        //Tells the delegate that the user tapped an Action button.
        return []
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        //Tells the delegate that the user dismissed the view.
    }
}
