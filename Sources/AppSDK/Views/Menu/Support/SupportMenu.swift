//
//  File.swift
//  
//
//  Created by Joe Manto on 5/28/23.
//

import Foundation
import AppKit
import WebKit

public class SupportMenu: NSMenu {
    
    static let supportTitle = NSLocalizedString("Support", comment: "")
    
    let parentItem: NSMenuItem
    
    public required init(parent: NSMenuItem) {
        self.parentItem = parent
        super.init(title: Self.supportTitle)
        self.setUp()
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        self.addItem(withTitle: Self.supportTitle, action: nil, keyEquivalent: "")
        self.addItem(NSMenuItem.separator())
        
        let welcomeItem = self.item(title: NSLocalizedString("Info", comment: ""),
                                    action: #selector(self.openWelcomeWindow(_:)),
                                    keyEquivalent: "", image: nil)
        self.addItem(welcomeItem)
        
        let featureItem = self.item(title: NSLocalizedString("Request a Feature", comment: ""),
                                    action: #selector(self.requestFeature(_:)),
                                    keyEquivalent: "", image: nil)
        self.addItem(featureItem)
        
        let bugItem = self.item(title: NSLocalizedString("Report a Bug", comment: ""),
                                action: #selector(self.reportBug(_:)),
                                keyEquivalent: "", image: nil)
        self.addItem(bugItem)
        
        let saveLogs = self.item(title: NSLocalizedString("Save Logs", comment: ""),
                                 action: #selector(self.saveLogs(_:)),
                                 keyEquivalent: "", image: nil)
        self.addItem(saveLogs)
        
        let resetLogs = self.item(title: NSLocalizedString("Reset Logs", comment: ""),
                                 action: #selector(self.resetLogs(_:)),
                                 keyEquivalent: "", image: nil)
        self.addItem(resetLogs)
    }
    
    private func item(title: String, action: Selector?, keyEquivalent: String, image: NSImage?) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        item.target = self
        item.image = image
        return item
    }
    
    // MARK: Selectors
    
    func showWebViewController(html: String) {
        guard let url = Bundle.module.url(forResource: html, withExtension: "html") else {
            assert(false, "Can't find welcome html file")
        }
        
        let vc = WKWebViewController()
        vc.initialURL = url
                
        let win = WindowManager.shared.create(root: vc, shouldShow: false)
        win.level = .tornOffMenu
        win.styleMask = [.closable, .titled]
        win.setFrame(NSRect(x: 0, y: 0, width: 500, height: 800), display: false, animate: false)
        win.moveWindow(location: .center)
        WindowManager.shared.showWindow(win)
    }
    
    @objc private func openWelcomeWindow(_ sender: NSButton) {
        self.showWebViewController(html: "welcome")
    }
    
    @objc private func reportBug(_ sender: NSButton) {
        self.showWebViewController(html: "bug")
    }
    
    @objc private func requestFeature(_ sender: NSButton) {
        self.showWebViewController(html: "feature")
    }
    
    @objc private func saveLogs(_ sender: NSButton) {
        Logging.shared.saveLogs()
    }
    
    @objc private func resetLogs(_ sender: NSButton) {
        Logging.shared.resetLogs()
    }
}
