//
//  SettingsMenu.swift
//
//
//  Created by Joe Manto on 4/23/23.
//

#if os(macOS)
import Foundation
import AppKit

extension NSMenu {
    
    static var selectors = [AppSettingKey: SelectorAction]()
    
    func appSettingsMenu() -> NSMenu {
        let menu = NSMenu()
        
        let settingsTitle = item(title: "Settings", action: nil, keyEquivalent: "", image: nil)
        menu.addItem(settingsTitle)
        
        let settingsSubMenu = NSMenu(title: "Settings")
        
        for (key, setting) in AppSettings.shared?.all ?? [:] {
            let action = SelectorAction(action: {
                setting.toggle()
            })
            Self.selectors[key] = action
            let item = self.settingItem(setting: setting, action: #selector(action.action))
            settingsSubMenu.addItem(item)
        }
        
        settingsSubMenu.addItem(NSMenuItem.separator())
        
        let resetItem = self.item(title: "Reset Settings", action: #selector(self.resetSettings(_:)), keyEquivalent: "", image: nil)
        settingsSubMenu.addItem(resetItem)
        
        return menu
    }
    
    private func item(title: String, action: Selector?, keyEquivalent: String, image: NSImage?) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: keyEquivalent)
        item.target = self
        item.image = image
        return item
    }
    
    private func settingItem(setting: AppSetting, action: Selector) -> NSMenuItem {
        let image = NSImage(named: "setting-\(setting.enabled ? "enabled" : "disabled")")
        let item = self.item(title: title, action: action, keyEquivalent: "", image: image)
        item.tag = setting.enabled ? 1 : 0
        return item
    }
    
    @objc func resetSettings(_ sender: Any) {
        AppSettings.shared?.resetSettings()
    }
}
#endif
