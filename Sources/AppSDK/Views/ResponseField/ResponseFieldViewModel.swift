//
//  ResponseFieldViewModel.swift
//  
//
//  Created by Joe Manto on 4/20/23.
//

import Foundation

public struct ResponseFieldSelection {
    public let options: [String]
    public let onSelection: (Int, String) -> ()
    
    public init(options: [String], onSelection: @escaping (Int, String) -> Void) {
        self.options = options
        self.onSelection = onSelection
    }
}

public struct ResponseFieldContent {
    public enum FieldType {
        case selection, action
    }
    
    public let title: String
    public let subtitle: String
    public let type: FieldType
    
    public init(title: String, subtitle: String, type: FieldType) {
        self.title = title
        self.subtitle = subtitle
        self.type = type
    }
}

public struct ResponseFieldAction {
    public let name: String
    public var destructive: Bool = false
    public let onAction: () -> ()
    
    public init(name: String, destructive: Bool, onAction: @escaping () -> Void) {
        self.name = name
        self.destructive = destructive
        self.onAction = onAction
    }
}

public class ResponseFieldViewModel {

    public var selection: ResponseFieldSelection?
    public var action: ResponseFieldAction?
    public let content: ResponseFieldContent
    public let fieldType: ResponseFieldContent.FieldType
    
    public required init(content: ResponseFieldContent) {
        self.content = content
        self.fieldType = self.content.type
    }
    
    public convenience init(content: ResponseFieldContent, action: ResponseFieldAction) {
        self.init(content: content)
        self.action = action
    }
    
    public convenience init(content: ResponseFieldContent, selection: ResponseFieldSelection) {
        self.init(content: content)
        self.selection = selection
    }
}
