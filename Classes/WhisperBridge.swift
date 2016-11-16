//
//  WhisperBridge.swift
//  Conversa
//
//  Created by Edgar Gomez on 3/25/16.
//  Copyright © 2016 Conversa. All rights reserved.
//

import Foundation
import Whisper

@objc public class WhisperBridge: NSObject {
    
    static public func whisper(text: String, backgroundColor: UIColor, toNavigationController: UINavigationController, silenceAfter: NSTimeInterval)
    {
        let message = Message(title: text, textColor: UIColor.whiteColor(), backgroundColor: backgroundColor, images: nil)
        show(whisper: message, to: toNavigationController)

        if silenceAfter > 0.1 {
            hide(whisperFrom: toNavigationController, after: silenceAfter)
        }
    }
    
    static public func shout(text: String, subtitle: String, backgroundColor: UIColor, toNavigationController: UINavigationController, image: UIImage? = nil, silenceAfter: NSTimeInterval, action: (() -> Void)? = nil)
    {
        let announcement = Announcement(title: text, subtitle: subtitle, image: image)
        show(shout: announcement, to: toNavigationController, completion: action)

        if silenceAfter > 0.1 {
            hide(whisperFrom: toNavigationController, after: silenceAfter)
        }
    }
}