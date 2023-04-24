//
//  SelectorAction.swift
//  
//
//  Created by Joe Manto on 4/23/23.
//

import Foundation

class SelectorAction: NSObject {

    private let _action: () -> ()

    init(action: @escaping () -> ()) {
        _action = action
        super.init()
    }

    @objc func action() {
        _action()
    }

}
