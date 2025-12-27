//
//  Logger.swift
//  SuperView
//
//  Created by Joe Manto on 9/19/21.
//

import Foundation
#if os(macOS)
import Cocoa
#endif
import SwiftUI

public enum LogType {
    case info, err, warn
}

public class Logging {
    
    public static let logFileUrlKey = "AppSDK-LOGFile"
    
    public static let shared = Logging()

    private var logFileHandle: FileHandle?

#if os(macOS)
    public func saveLogs() {
        guard let url = UserDefaults.standard.url(forKey: Self.logFileUrlKey) else {
            Logging.shared.log(msg: "Couldn't get logs url", comp: "[Logging]", type: .err)
            return
        }
    
        let savePanel = NSSavePanel()
        savePanel.level = .modalPanel
        savePanel.begin { (result) in
            guard result == NSApplication.ModalResponse.OK,
                  let dstUrl = savePanel.url else {
                return
            }
            
            do {
                try FileManager().copyItem(at: url, to: dstUrl)
            }
            catch {
                Logging.shared.log(msg: "Couldn't copy logs to path \(dstUrl.absoluteString)", comp: "[Logging]", type: .err)
            }
        }
    }
#endif

    public func resetLogs() {
        self.removeLogFile()
        try? self.createNewLogFile().close()
    }
    
    private func removeLogFile() {
        guard let url = UserDefaults.standard.url(forKey: Self.logFileUrlKey) else {
            return
        }
        
        try? FileManager().removeItem(atPath: url.path)
    }
    
    private func createNewLogFile() throws -> FileHandle {
        self.removeLogFile()
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let temporaryFilename = ProcessInfo().globallyUniqueString
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
        
        FileManager().createFile(atPath: temporaryFileURL.path, contents: nil, attributes: [:])
        
        UserDefaults.standard.set(temporaryFileURL, forKey: Self.logFileUrlKey)
       
        return try FileHandle(forUpdating: temporaryFileURL)
    }

    private func getLogFileHandle() throws -> FileHandle {
        if let logFileHandle {
            return logFileHandle
        }

        let newHandle = try openNewLogFileForWriting()
        self.logFileHandle = newHandle
        return newHandle
    }

    private func openNewLogFileForWriting() throws -> FileHandle {
        return if let url = UserDefaults.standard.url(forKey: Self.logFileUrlKey) {
            try FileHandle(forUpdating: url)
        } else {
            try createNewLogFile()
        }
    }
    
    public func log(marker: String) {
        let msg = "-------------------\(marker)-------------------"
        self.log(msg: msg)
    }

    public func log(msg: String, comp: String = "[-]", type: LogType = .info) {
        guard let fileHandler = try? getLogFileHandle() else {
            return
        }

        do {
            guard (try fileHandler.seekToEnd()) != nil else {
                try fileHandler.close()
                return
            }
        } catch {
            print("Failed to close file handle \(error)")
        }

        var component = comp
        if comp.count < 15 {
            component.append(String.init(repeating: " ", count: 15 - comp.count))
        }
        
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = format.string(from: Date())
        
        var logType: String = ""
        switch type {
            case .err:
                logType = "[E]"
            case .warn:
                logType = "[W]"
            case .info:
                logType = "[I]"
        }
        
        let logMessage = "\(date)+\(logType)+\(component) \(msg)\n"
        print(logMessage)
        
        fileHandler.write(logMessage.data(using: .utf8) ?? Data())
    }
}

public func log(_ type: LogType, _ msg: String, comp: String = "[-]") {
    Logging.shared.log(msg: msg, comp: comp, type: type)
}
