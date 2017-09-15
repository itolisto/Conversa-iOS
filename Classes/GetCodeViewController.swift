//
//  GetCodeViewController.swift
//  Conversa
//
//  Created by Edgar Gomez on 9/14/17.
//  Copyright © 2017 Conversa. All rights reserved.
//

import UIKit

class GetCodeViewController: UIViewController {

    @IBOutlet weak var ivGif: UIImageView!
    @IBOutlet weak var btnGetCode: UIStateButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        ivGif.loadGif(name: "gifCode")

        self.btnGetCode.setBackgroundColor(UIColor.clear, for: .normal)
        self.btnGetCode.setTitleColor(Colors.green(), for: .normal)
        self.btnGetCode.setBackgroundColor(Colors.green(), for: .highlighted)
        self.btnGetCode.setTitleColor(UIColor.white, for: .highlighted)
    }
    
    @IBAction func getCodeButtonPressed(_ sender: UIStateButton) {
        let textToShare = NSLocalizedString("settings_home_share_text", comment: "")
        let myWebsite = NSURL.init(string: "http://descarga.conversachat.com")

        let objectsToShare = [textToShare, myWebsite ?? ""] as [Any]

        let activityVC : UIActivityViewController = UIActivityViewController.init(activityItems: objectsToShare, applicationActivities: nil)

        let excludeActivities = [UIActivityType.airDrop,
        UIActivityType.print,
        UIActivityType.assignToContact,
        UIActivityType.saveToCameraRoll,
        UIActivityType.addToReadingList,
        UIActivityType.postToFlickr,
        UIActivityType.postToVimeo]

        activityVC.excludedActivityTypes = excludeActivities;

        self.present(activityVC, animated: true, completion: nil)
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
