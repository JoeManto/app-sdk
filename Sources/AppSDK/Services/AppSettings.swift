//
//  AppSettings.swift
//  
//
//  Created by Joe Manto on 4/23/23.
//

import Foundation

public struct AppSetting {
    public let key: AppSettingKey
    public let title: String
    public let description: String
    public let defaultValue: Bool
    
    public var enabled: Bool {
        AppSettings.shared?.defaults.bool(forKey: key.rawValue) ?? false
    }
    
    public func toggle() {
        AppSettings.shared?.toggle(key)
    }
    
    public func reset() {
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
    
    public static var suiteName: String?
    
    lazy var defaults: UserDefaults = {
        UserDefaults(suiteName: Self.suiteName) ?? UserDefaults.standard
    }()
    
    public var all: [AppSettingKey: AppSetting] {
        self.provider.appSettings()
    }
    
    public func toggle(_ key: AppSettingKey) {
        guard let setting = provider.appSettings()[key] else {
            return
        }
        
        self.defaults.set(!setting.enabled, forKey: setting.key.rawValue)
    }
    
    public func get(_ key: AppSettingKey) -> AppSetting! {
        provider.appSettings()[key]
    }
    
    public func resetSettings() {
        for (_, setting) in provider.appSettings() {
            setting.reset()
        }
    }
}
