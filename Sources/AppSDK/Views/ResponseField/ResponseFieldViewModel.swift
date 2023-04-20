//
//  ResponseFieldViewModel.swift
//  
//
//  Created by Joe Manto on 4/20/23.
//

import Foundation

struct ResponseFieldSelection {
    let options: [String]
    let onSelection: (Int, String) -> ()
}

struct ResponseFieldContent {
    enum FieldType {
        case selection, action
    }
    
    let title: String
    let subtitle: String
    let type: FieldType
}

struct ResponseFieldAction {
    let name: String
    var destructive: Bool = false
    let onAction: () -> ()
}

class ResponseFieldViewModel {

    var selection: ResponseFieldSelection?
    var action: ResponseFieldAction?
    let content: ResponseFieldContent
    let fieldType: ResponseFieldContent.FieldType
    
    required init(content: ResponseFieldContent) {
        self.content = content
        self.fieldType = self.content.type
    }
    
    convenience init(content: ResponseFieldContent, action: ResponseFieldAction) {
        self.init(content: content)
        self.action = action
    }
    
    convenience init(content: ResponseFieldContent, selection: ResponseFieldSelection) {
        self.init(content: content)
        self.selection = selection
    }
}
