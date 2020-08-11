//
//  TestLogger.swift
//  testSearch
//
//  Created by Scott Kovatch on 8/7/20.
//  Copyright © 2020 Ascoware LLC. All rights reserved.
//

import Foundation

class TestLogger: Logging {
    
    public func addToLog(_ string: String) {
        addToLog(string, sender: nil)
    }

    public func addToLog(_ string: String, sender: Any?) {
        var msg = ""
        
        if let sender = sender as? NSObject {
            msg += sender.description
        }
        msg += string
        print(msg)
    }
}
