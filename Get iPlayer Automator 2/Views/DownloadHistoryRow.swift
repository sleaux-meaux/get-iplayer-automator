//
//  DownloadHistoryRow.swift
//  Get iPlayer Automator 2
//
//  Created by Scott Kovatch on 8/8/20.
//  Copyright © 2020 Ascoware LLC. All rights reserved.
//

import SwiftUI

struct DownloadHistoryRow: View {
    var downloadedShow: DownloadedProgram
    
    var body: some View {
        HStack {
            Text(downloadedShow.episodeTitle)
            Spacer()
            Text(downloadedShow.downloadTimeString)
        }
    }
}

struct DownloadHistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        DownloadHistoryRow(downloadedShow: downloadedFileExamples[1])
    }
}
