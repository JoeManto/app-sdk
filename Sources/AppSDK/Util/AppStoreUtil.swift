//
//  AppStoreUtil.swift
//  
//
//  Created by Joe Manto on 4/27/23.
//

import Foundation

public struct AppStoreUtil {
    
    public static func getAppStoreVersion(appBundleId: String) async -> String? {
        let request = URLRequest(url: URL(string: "https://itunes.apple.com/lookup?bundleId=\(appBundleId)")!)
        
        let networkResponse: (data: Data, response: URLResponse)
        do {
            networkResponse = try await URLSession.shared.data(for: request)
        } catch {
            Logging.shared.log(msg: "Request to get app store version failed error: \(error)")
            return nil
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: networkResponse.data, options: []) as? [String : Any] else {
            Logging.shared.log(msg: "unable to convert response to json")
            return nil
        }
        
        guard let results = json["results"] as? [Any],
              let version = (results.first as? [String : Any])?["version"] as? String else {
            Logging.shared.log(msg: "unable to get version")
            return nil
        }
        
        return version
    }
}
