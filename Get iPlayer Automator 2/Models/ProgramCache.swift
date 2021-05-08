//
//  ProgramCache.swift
//  Get iPlayer Automator 3
//
//  Created by Scott Kovatch on 7/19/20.
//

import Foundation

class ProgramCache: ObservableObject {
    var programs: [Programme] = []

    
}


class TestProgramCache: ProgramCache {
    
    public override init() {
        super.init()
        programs = [
            Programme(), Programme(), Programme(), Programme(), Programme(), Programme(), Programme()
        ]
    }
}
