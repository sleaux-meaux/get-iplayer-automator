//
//  Program.swift
//  Get iPlayer Automator 3
//
//  Created by Scott Kovatch on 7/19/20.
//

import Foundation
import SwiftUI

public class Program : ObservableObject, Identifiable, CustomStringConvertible {
    public var id = UUID()
    
    var series: Series?
    var pid: String = "" {
        didSet {
            pid = pid.replacingOccurrences(of: ";amp", with: "&")
        }
    }
    var status: String = ""
    var title: String = ""
//    {
//        didSet {
//            title = title.removingPercentEncoding
//        }
//
//    }
    var episodeTitle: String = ""
    var network: String = ""
    var season: Int = 0
    var episode: Int = 0
    var episodeCount: Int = 0
    var isRadio: Bool = false
    var isPodcast: Bool = false
    var subtitlePath: String = ""
    var availableModes: String = ""
    var url: String = ""
    var dateAired = Date()
    var standardizedDate = ""
    var summary = ""
    
    var timeAdded = Date()
    
    var complete = false
    var successful = false
    var failureReason = ""
    var addedByPVR = false
    
    // FIXME: Is this needed?
    var realPID = ""
        
    //Extended Metadata
    var attemptedExtendedMetadata = false
    var extendedMetadataSuccess = false
    var duration: Int = 0
    var categories = ""
    var firstBroadcast: Date?
    var lastBroadcast: Date?
    var modeSizes: [String] = []
    var thumbnailURL = ""
    var thumbnail: Image?

    //var metadataTask: GetiPlayerTask?
    
    public var description: String {
        return "title = \(title), episodeTitle = \(episodeTitle), date = \(standardizedDate)"
    }
}
