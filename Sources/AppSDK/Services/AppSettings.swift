//
//  AppSettings.swift
//  
//
//  Created by Joe Manto on 4/23/23.
//

import Foundation

public struct AppSetting {
    let key: AppSettingKey
    let title: String
    let description: String
    let defaultValue: Bool
    
    var enabled: Bool {
        AppSettings.shared?.defaults.bool(forKey: key.rawValue) ?? false
    }
    
    func toggle() {
        AppSettings.shared?.toggle(key)
    }
    
    func reset() {
        AppSettings.shared?.defaults.set(defaultValue, forKey: key.rawValue)
    }
}

public enum AppSettingKey: String, CaseIterable {
    case app = "appsdk.app"
}

public protocol AppSettingsProvider {
    func appSettings() -> [AppSettingKey: AppSetting]
}



public class AppSettings {
        
    public static var shared: AppSettings?
    
    let provider: AppSettingsProvider
    
    init(provider: AppSettingsProvider) {
        self.provider = provider
    }
    
    static var suiteName: String?
    
    lazy var defaults: UserDefaults = {
        UserDefaults(suiteName: Self.suiteName) ?? UserDefaults.standard
    }()
    
    var all: [AppSettingKey: AppSetting] {
        self.provider.appSettings()
    }
    
    func toggle(_ key: AppSettingKey) {
        guard let setting = provider.appSettings()[key] else {
            return
        }
        
        self.defaults.set(!setting.enabled, forKey: setting.key.rawValue)
    }
    
    func get(_ key: AppSettingKey) -> AppSetting! {
        provider.appSettings()[key]
    }
    
    func resetSettings() {
        for (_, setting) in provider.appSettings() {
            setting.reset()
        }
    }
}
