//
//  DownloadedProgram.swift
//  Get iPlayer Automator 2
//
//  Created by Scott Kovatch on 8/7/20.
//  Copyright © 2020 Ascoware LLC. All rights reserved.
//

import Foundation

struct DownloadedProgram: Identifiable, Hashable, Codable {

    var id: String {
        return pid
    }
    //= UUID()
    let pid: String
    let title: String
    let episodeTitle: String
    let type: String
    let downloadTime: String
    let downloadFormat: String
    let downloadPath: String
    
    var entryString: String {
        let fields = [pid, title, episodeTitle, type, downloadTime, downloadFormat, downloadPath]
        return fields.joined(separator: "|")
    }

    var downloadTimeString: String {
        guard let downloadSecs = Double(downloadTime) else {
            return "Unknown"
        }
        let date = Date(timeIntervalSince1970: downloadSecs)
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .medium)
    }
}
