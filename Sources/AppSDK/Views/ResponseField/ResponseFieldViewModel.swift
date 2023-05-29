//
//  ResponseFieldViewModel.swift
//  
//
//  Created by Joe Manto on 4/20/23.
//

import Foundation

public enum FieldType {
    case selection, confirm, action
}

public protocol ResponseFieldContent {
    var name: String { get }
    var subtitle: String { get }
    var type: FieldType { get }
}

public struct ResponseFieldAction: ResponseFieldContent {
    public let type: FieldType = .action
    public let name: String
    public var subtitle: String
    
    public var btnTitle: String
    public var destructive: Bool = false
    public var dur: Int
    public let onAction: (() -> ())?
    
    public init(name: String, btnTitle: String, subtitle: String, destructive: Bool = false, dur: Int = 3, onAction: (() -> Void)? = nil) {
        self.name = name
        self.btnTitle = btnTitle
        self.subtitle = subtitle
        self.destructive = destructive
        self.dur = dur
        self.onAction = onAction
    }
}

public struct ResponseFieldSelection: ResponseFieldContent {
    public let type: FieldType = .selection
    public var name: String
    public var subtitle: String
    
    public let options: [String]
    public var onSelection: ((Int, String) -> ())?
    
    public init(name: String, subtitle: String, options: [String], onSelection: ((Int, String) -> Void)? = nil) {
        self.name = name
        self.subtitle = subtitle
        self.options = options
        self.onSelection = onSelection
    }
}

public class ResponseFieldViewModel {
    public let content: ResponseFieldContent

    public required init(content: ResponseFieldContent) {
        self.content = content
    }
}
