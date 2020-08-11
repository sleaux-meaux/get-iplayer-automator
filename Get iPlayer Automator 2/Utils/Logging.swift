//
//  Logging.swift
//  Get iPlayer Automator 2
//
//  Created by Scott Kovatch on 8/7/20.
//  Copyright © 2020 Ascoware LLC. All rights reserved.
//

import Foundation

protocol Logging {
    func addToLog(_ string: String)
    func addToLog(_ string: String, sender: Any?)
}
