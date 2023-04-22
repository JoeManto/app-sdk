//
//  File.swift
//  
//
//  Created by Joe Manto on 4/22/23.
//

import Foundation
import AppKit

struct AppSDKUtil {
    static func showStoreKitAlert(title: String, msg: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = msg
            alert.addButton(withTitle: NSLocalizedString("Ok", comment: ""))
            alert.runModal()
        }
    }
}

