//
//  SelectorAction.swift
//  
//
//  Created by Joe Manto on 4/23/23.
//

import Foundation

public class SelectorAction: NSObject {

    private let _action: () -> ()

    public init(action: @escaping () -> ()) {
        _action = action
        super.init()
    }

    @objc public func action() {
        _action()
    }
}
