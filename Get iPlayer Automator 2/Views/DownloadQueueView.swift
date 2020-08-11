//
//  DownloadQueueView.swift
//  Get iPlayer Automator 3
//
//  Created by Scott Kovatch on 7/18/20.
//

import SwiftUI

struct DownloadQueueView: View {
    @ObservedObject var queuedShows: DownloadQueue
        
    var body: some View {
        List {
            ForEach (queuedShows.programs) { queuedShow in
                HStack {
                    Text(queuedShow.title)
                    Spacer()
                    Text(queuedShow.series?.name ?? "None")
                    Spacer()
                    Text(DateFormatter().string(from: queuedShow.dateAired))
                }
            }
        }
    }
}

struct DownloadQueueView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadQueueView(queuedShows: DownloadQueue())
    }
}
