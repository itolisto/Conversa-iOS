//
//  WhisperBridge.swift
//  Conversa
//
//  Created by Edgar Gomez on 3/25/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

import UIKit
import Whisper

@objc open class WhisperBridge: NSObject {

    static open func whisper(_ text: String, backgroundColor: UIColor, toNavigationController: UINavigationController, silenceAfter: TimeInterval)
    {
        let message = Message(title: text, textColor: UIColor.white, backgroundColor: backgroundColor, images: nil)
        show(whisper: message, to: toNavigationController)

        if silenceAfter > 0.1 {
            hide(whisperFrom: toNavigationController, after: silenceAfter)
        }
    }
    
    static open func shout(_ text: String, subtitle: String, backgroundColor: UIColor, toNavigationController: UINavigationController, image: UIImage? = nil, silenceAfter: TimeInterval, action: (() -> Void)? = nil)
    {
        let announcement = Announcement(title: text, subtitle: subtitle, image: image)
        show(shout: announcement, to: toNavigationController, completion: action)
    }

}
