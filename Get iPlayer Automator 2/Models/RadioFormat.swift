//
//  RadioFormat.swift
//  Get iPlayer Automator 3
//
//  Created by Scott Kovatch on 8/4/20.
//

import Foundation

struct RadioFormat {
    let format: String
    let description: String
}

// BBC radio quality
let radioBest = RadioFormat(format: "radiobest", description: "Best")
let radioBetter = RadioFormat(format: "radiobetter", description: "Better")
let radioGood = RadioFormat(format: "radiogood", description: "Good")
let radioWorst = RadioFormat(format: "radioworst", description: "Worst")

let radioFormats = [radioBest, radioBetter, radioGood, radioWorst]
