//
//  DownloadHistory.swift
//  Get iPlayer Automator 2
//
//  Created by Scott Kovatch on 8/7/20.
//  Copyright © 2020 Ascoware LLC. All rights reserved.
//

import Foundation

enum HistoryError: Error {
    case cantCreateArchiveError
    case cantGetArchivePathError
    case cantCreateFileError
    case cantOverwriteFileError
}

class DownloadHistory: ObservableObject {
    
    var downloadedShows: [DownloadedProgram] = []
    let historyFileURL = FileManager.default.applicationSupportDirectory.appendingPathComponent("download_history")

    public func readHistory() {
        do {
            let historyFileData = try Data(contentsOf: historyFileURL)
            let history = String(data: historyFileData, encoding: .utf8)
            let entries = history?.components(separatedBy: .newlines)
            downloadedShows = []
            
            entries?.forEach({
                // m000kbx9|Inside Monaco: Playground of the Rich: Series 1|03. Episode 3|tv|1592875821|hvfhd1|/Users/skovatch/Movies/TV Shows/Inside Monaco Playground of the Rich/Inside Monaco Playground of the Rich.s01e03.Episode 3.mp4
                
                let fields = $0.split(separator: "|")
                
                let pid = String(fields[0])
                let title = String(fields[1])
                let episode = String(fields[2])
                let type = String(fields[3])
                let something = String(fields[4])
                let format = String(fields[5])
                let dlPath = String(fields[6])
                
                let historyItem = DownloadedProgram(pid: pid, title: title, episodeTitle: episode, type: type, downloadTime: something, downloadFormat: format, downloadPath: dlPath)
                downloadedShows.append(historyItem)
            })
        } catch {
            // help?
        }
    }
    
    public func writeHistory() {
        var historyString = ""
        
        downloadedShows.forEach {
            historyString += $0.entryString
            historyString += "\n"
        }
        
        do {
            guard let historyData = historyString.data(using: .utf8) else {
                print("Something went wrong creating data from history string")
                throw HistoryError.cantCreateArchiveError
            }

            try historyData.write(to: historyFileURL)
        } catch {
            
        }
    }
//    {
//    NSAlert *alert = [[NSAlert alloc] init];
//    alert.informativeText = @"Your changes have been discarded.";
//    alert.messageText = @"Download History cannot be edited while downloads are running.";
//    [alert addButtonWithTitle:@"OK"];
//    [alert runModal];
//    [historyWindow close];
//    }
//    [saveButton setEnabled:NO];
//    [historyWindow setDocumentEdited:NO];
//}
//
//-(IBAction)showHistoryWindow:(id)sender
//{
//    if (!runDownloads)
//    {
//        if (!historyWindow.documentEdited) [self readHistory:self];
//        [historyWindow makeKeyAndOrderFront:self];
//        saveButton.enabled = historyWindow.documentEdited;
//    }
//    else
//    {
//        NSAlert *alert = [NSAlert new];
//        alert.messageText = @"Download History cannot be edited while downloads are running.";
//        [alert runModal];
//    }
//}
}
