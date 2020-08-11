//
//  TVFormat.swift
//  Get iPlayer Automator 3
//
//  Created by Scott Kovatch on 8/4/20.
//

import Foundation

struct TVFormat {
    let format: String
    let description: String
}

// BBC formats
let bbcTvBest = TVFormat(format: "tvbest", description: "Best")
let bbcTvBetter = TVFormat(format: "tvbetter", description: "Better")
let bbcTvGood = TVFormat(format: "tvgood", description: "Good")
let bbcTvWorst = TVFormat(format: "tvworst", description: "Worst")

let bbcFormats = [bbcTvBest, bbcTvBetter, bbcTvGood, bbcTvWorst]

// ITV formats
let itvBest  = TVFormat(format: "itvbest", description: "HD")
let itvBetter  = TVFormat(format: "itvbetter", description: "Very Good")
let itvGood  = TVFormat(format: "itvgood", description: "Good")

let itvFormats = [itvBest, itvBetter, itvGood]
