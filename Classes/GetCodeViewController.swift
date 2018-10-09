//
//  GetCodeViewController.swift
//  Conversa
//
//  Created by Edgar Gomez on 9/14/17.
//  Copyright © 2017 Conversa. All rights reserved.
//

import UIKit
import SafariServices
import TTTAttributedLabel

class GetCodeViewController: UIViewController {

    @IBOutlet weak var ivGif: UIImageView!
    @IBOutlet weak var btnGetCode: UIStateButton!
    @IBOutlet weak var lblShare: TTTAttributedLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ivGif.loadGif(name: "gifCode")

        self.btnGetCode.setBackgroundColor(UIColor.clear, for: .normal)
        self.btnGetCode.setTitleColor(Colors.green(), for: .normal)
        self.btnGetCode.setBackgroundColor(Colors.green(), for: .highlighted)
        self.btnGetCode.setTitleColor(UIColor.white, for: .highlighted)
        
        let text = self.lblShare.text as? String ?? ""

        let attrStr = NSMutableAttributedString.init(string: text, attributes: nil)

        let str = NSLocale.preferredLanguages[0]
        let index = str.index(str.startIndex, offsetBy: 2)

        let language = String(str[..<index])
        let size = text.count

        var start, startThis, normalOne, normalTwo : NSRange;

        start = NSMakeRange(size - 29, 29);

        if (language == "es") {
            normalOne = NSMakeRange(0, 10);
            normalTwo = NSMakeRange(16, size - 29);
            startThis = NSMakeRange(11, 4);
        } else {
            normalOne = NSMakeRange(0, 8);
            normalTwo = NSMakeRange(14, size - 29);
            startThis = NSMakeRange(9, 4);
        }

        /// Normal
        let attributesNormal: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.light)]
        attrStr.setAttributes(attributesNormal, range: normalOne)
        attrStr.setAttributes(attributesNormal, range: normalTwo)
        // Green
        let attributesGreen: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: Colors.green(), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.light)]
        attrStr.setAttributes(attributesGreen, range: start)
        attrStr.setAttributes(attributesGreen, range: startThis)


        let url = NSURL(string: "https://conversachat.com")! as URL

        self.lblShare.addLink(to: url, with: startThis)
        self.lblShare.attributedText = attrStr;
        self.lblShare.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue //NSTextCheckingTypeLink;
        self.lblShare.delegate = self;
    }
    
    @IBAction func getCodeButtonPressed(_ sender: UIStateButton) {
        let svc = SFSafariViewController.init(url: NSURL(string: "http://codigos.conversachat.com")! as URL, entersReaderIfAvailable: false)
        svc.delegate = self;
        self.present(svc, animated: true, completion: nil)
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        if let parent = self.navigationController {
            parent.popToRootViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }

}

extension GetCodeViewController : TTTAttributedLabelDelegate {

    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        let textToShare = NSLocalizedString("gcvc_alert_share", comment: "")

        let objectsToShare = [textToShare] as [Any]

        let activityVC : UIActivityViewController = UIActivityViewController.init(activityItems: objectsToShare, applicationActivities: nil)

        let excludeActivities = [UIActivity.ActivityType.airDrop,
                                 UIActivity.ActivityType.print,
                                 UIActivity.ActivityType.assignToContact,
                                 UIActivity.ActivityType.saveToCameraRoll,
                                 UIActivity.ActivityType.addToReadingList,
                                 UIActivity.ActivityType.postToFlickr,
                                 UIActivity.ActivityType.postToVimeo]

        activityVC.excludedActivityTypes = excludeActivities;

        self.present(activityVC, animated: true, completion: nil)
    }

}

extension GetCodeViewController : SFSafariViewControllerDelegate {

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

