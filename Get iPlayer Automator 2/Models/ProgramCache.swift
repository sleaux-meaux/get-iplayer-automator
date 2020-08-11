//
//  ProgramCache.swift
//  Get iPlayer Automator 3
//
//  Created by Scott Kovatch on 7/19/20.
//

import Foundation

class ProgramCache: ObservableObject {
    var programs: [Program] = []

    
}


class TestProgramCache: ProgramCache {
    
    public override init() {
        super.init()
        programs = [
            Program(), Program(), Program(), Program(), Program(), Program(), Program()
        ]
    }
}
