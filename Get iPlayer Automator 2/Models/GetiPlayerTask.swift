//
//  GetiPlayerTask.swift
//  Get iPlayer Automator 3
//
//  Created by Scott Kovatch on 7/19/20.
//

import Foundation

class GetiPlayerTask {
    var task: Process?
    var pipe: Pipe?
    var errorPipe: Pipe?
    var fh: FileHandle?
    var errorFh: FileHandle?
}
