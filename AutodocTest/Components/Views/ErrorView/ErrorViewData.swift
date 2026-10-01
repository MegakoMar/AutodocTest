//
//  ErrorViewData.swift
//  AutodocTest
//
//  Created by Roman Komarov on 01.10.2026.
//

import Foundation

struct ErrorViewData {
    let message: String
    var type: State = .empty
    var action: (() -> Void)? = nil
    
    enum State {
        case error
        case empty
    }
}
