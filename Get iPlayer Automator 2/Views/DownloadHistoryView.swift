//
//  DownloadHistoryView.swift
//  Get iPlayer Automator 2
//
//  Created by Scott Kovatch on 8/8/20.
//  Copyright © 2020 Ascoware LLC. All rights reserved.
//

import SwiftUI

struct DownloadHistoryView: View {

    var showsWithEpisodes: [String: [DownloadedProgram]] {
        Dictionary(
            grouping: downloadedFileExamples,
            by: { $0.title }
        )
    }


    //@State var canEditHistory = true
   // @ObservedObject var downloadHistory: DownloadHistory
    //@State var selectedItem: DownloadedProgram? = nil
    
    var body: some View {
        List {
            ForEach (showsWithEpisodes.keys.sorted(), id: \.self) { key in
                Text(key)
            }
//            }(downloadedFileExamples) { show in
//            DownloadHistoryRow(downloadedShow: show)
        }
    }
}

struct DownloadHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadHistoryView()
    }
}
