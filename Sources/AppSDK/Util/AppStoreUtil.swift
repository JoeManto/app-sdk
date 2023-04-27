//
//  AppStoreUtil.swift
//  
//
//  Created by Joe Manto on 4/27/23.
//

import Foundation

struct AppStoreUtil {
    
    static func getAppStoreVersion(appBundleId: String) async -> String? {
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

/*
let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
    guard error == nil else {
        onFailure("checking app udate status \(String(describing: error?.localizedDescription))")
        return
    }
    guard let httpResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode) else {
            onFailure(" server error: got response code \((response as? HTTPURLResponse)?.statusCode ?? -1) ")
        return
    }
    guard let mimeType = httpResponse.mimeType, mimeType == "text/javascript",
          let data = data else {
        onFailure("incorrect mime type or didn't get any data")
        return
    }
    
    guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] else {
        onFailure("unable to convert responce to json")
        return
    }

    guard let results = json["results"] as? [Any],
          var version = (results.first as? [String : Any])?["version"] as? String else {
        onFailure("unable to get version")
        return
    }
    
    guard var currentVersion = (Bundle.main.infoDictionary)?["CFBundleShortVersionString"] as? String else {
        onFailure("Unable to get current app version")
        return
    }
    
    if let mockLocalVersion = mockLocalVersion,
       let mockAppStoreVersion = mockAppStoreVersion {
        currentVersion = mockLocalVersion
        version = mockAppStoreVersion
    }
    
    var isOutDated = false
    if (currentVersion != version) {
        isOutDated = true
        Settings.shared.setValue(true, forKey: Setting.isOutDated, log: true)
    }
    
    DispatchQueue.main.async {
        comp?(isOutDated)
    }
    Logging.shared.log(msg: "[Util] was able to fetch Version data. Current Local Version \(currentVersion) App Store Version: \(version)")
})
task.resume()*/
