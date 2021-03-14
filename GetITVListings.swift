//  GetITVListings.swift
//  ITVLoader
//
//  Created by Scott Kovatch on 3/16/18
//

import Foundation
import Kanna
import SwiftyJSON

public class GetITVShows: NSObject {
    var showQueueSize = 0
    var showQueueLeft = 0
    var episodeQueueSize = 0
    var episodeQueueLeft = 0
    let mySession: URLSession = {
        let defaultConfigObject = URLSessionConfiguration.ephemeral
        defaultConfigObject.timeoutIntervalForResource = 90
        defaultConfigObject.timeoutIntervalForRequest = 90
        return URLSession(configuration: defaultConfigObject, delegate: nil, delegateQueue: OperationQueue.main)
    }()
    
    var programmeURLs = [URL]()
    var episodeURLs = [URL]()
    var episodes = [Programme]()

    var getITVShowRunning = false
    var logger: LogController?
    var myOpQueue = OperationQueue()
    
    func supportPath(_ fileName: String) -> String
    {
        if let applicationSupportDir = FileManager.default.applicationSupportDirectory() {
            return applicationSupportDir.appending("/").appending(fileName)
        }
        
        return NSHomeDirectory().appending("/.get_iplayer/").appending(fileName)
    }
    
    public override init() {
        super.init()
        myOpQueue.maxConcurrentOperationCount = 1
    }
    
    @objc public func itvUpdate(newLogger: LogController) {
        /* cant run if we are already running */
        if getITVShowRunning == true {
            return
        }
        logger = newLogger
        logger?.add(toLog: "GetITVShows: ITV Cache Update Starting ")
        getITVShowRunning = true
        programmeURLs = []
        showQueueSize = 0
        episodeURLs = []
        episodeQueueSize = 0

        if let aString = URL(string: "https://www.itv.com/hub/shows") {
            mySession.dataTask(with: aString) {(data, _, error) -> Void in
                if let error = error {
                    let errorMessage = "GetITVListings (Error: \(error.localizedDescription)): Unable to retreive show listings from ITV"
                    self.logger?.add(toLog: errorMessage)
                }
                guard let data = data else {
                    self.endOfRun()
                    return
                }
                
                if self.createProgrammes(data: data) {
                    self.showQueueSize = self.programmeURLs.count
                    self.showQueueLeft = self.showQueueSize

                    if self.showQueueSize >= 0 {
                        for programURL in self.programmeURLs {
//                            self.myOpQueue.addOperation {
                                self.requestProgrammeEpisodes(programUrl: programURL)
//                            }
                        }
                    } else {
                        self.writeEpisodeCacheFile()
                    }
                    
                } else {
                    self.endOfRun()
                }
            }.resume()
        }
    }
    
    func createProgrammes(data: Data) -> Bool {
        /* Scan itv.com/shows to create full listing of programmes (not episodes) that are available today */
        programmeURLs.removeAll()
        
        if let showsPage = try? HTML(html: data, encoding: .utf8) {
            let shows = showsPage.xpath("//a[@class='complex-link']")
            
            for show in shows {
                guard let showPage = show.at_xpath("@href")?.text,
                    let showPageURL = URL(string: showPage) else {
                        continue
                }

                let productionID = showPageURL.lastPathComponent

                // Check for duplicate show listings.
                let existingProgram = programmeURLs.filter { $0.lastPathComponent == productionID }

                if existingProgram.count == 0 {
                    programmeURLs.append(showPageURL)
                }
            }
        }

        /* Now we sort the programmes and drop the duplicates */
        if programmeURLs.count == 0 {
            self.logger?.add(toLog: "No programmes found on www.itv.com/hub/shows")
            showAlert(message: "No programmes were found on www.itv.com/hub/shows",
                      informative: "Try again later. If the problem persists please file a bug.")
            return false
        }
        
        return true
    }

    func requestProgrammeEpisodes(programUrl: URL) {
        /* Get all episodes for the programme name identified in MyProgramme */
        if programUrl.absoluteString.contains("ninjawarrior") {
            print("WAIT HERE!!!")
        }
        mySession.dataTask(with: programUrl) {(data, _, error) -> Void in
            self.processEpisodesForProgram(url: programUrl, pageData: data, error: error)
        }.resume()
    }
//
//    func dateForTimeString(_ time:String) -> Date? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
//        dateFormatter.timeZone = TimeZone(secondsFromGMT:0)
//        return dateFormatter.date(from: time)
//    }
        
    func processEpisodeElement(url: URL, show: Kanna.XMLElement) {
        let programURL = url.deletingLastPathComponent()
        guard let episodeURLString = show.at_xpath("@href")?.text,
              let episodeURL = URL(string: episodeURLString) else {
            return
        }

        // Make sure the URL matches the show listing -- ITV likes to sneak other shows on a program page.
        let episodeURLBase = episodeURL.deletingLastPathComponent()
        if episodeURLBase == programURL {
            self.episodeURLs.append(episodeURL)
        }
    }
    
    func processSingleEpisode(html: HTMLDocument) {
        if let descriptionElement = html.at_xpath("//script[@id=\"json-ld\"]"), let descriptionJSON = descriptionElement.content {
            let descriptionData = JSON(parseJSON: descriptionJSON)
            let breadcrumbs = descriptionData["itemListElement:"].arrayValue
            for item in breadcrumbs {
                if item["item:"]["@type"] == "TVEpisode" {
                    let showMetadata = item["item:"]
                    let urlString = showMetadata["@id"].stringValue
                    if let url = URL(string: urlString) {
                        self.episodeURLs.append(url)
                        break
                    }
                }
            }
        }
    }

    fileprivate func seriesOperationCompleted() {
        /* Check if there is any outstanding work before processing the carried forward programme list */
        showQueueLeft -= 1
        if (showQueueLeft == 0) {
            fetchEpisodeURLs()
        }
    }

    fileprivate func episodeOperationCompleted() {
        AppController.shared().itvProgressIndicator.isIndeterminate = false
        let increment = Double(episodeQueueSize - 1) > 0 ? 100.0 / Double(episodeQueueSize - 1) : 100.0
        AppController.shared().itvProgressIndicator.increment(by: increment)

        /* Check if there is any outstanding work before processing the carried forward programme list */
        episodeQueueLeft -= 1
        if (episodeQueueLeft == 0) {
            writeEpisodeCacheFile()
        }
    }

    func processEpisodesForProgram(url: URL, pageData: Data?, error: Error?) {
        if let error = error {
            let errorMessage = "GetITVListings (Error(\(error))): Unable to retreive programme episodes for \(url.absoluteString)"
            self.logger?.add(toLog: errorMessage)
            seriesOperationCompleted()
            return
        }

        guard let pageData = pageData else {
            seriesOperationCompleted()
            return
        }
        
        if let showPageHTML = try? HTML(html: pageData, encoding: .utf8) {
            let episodeElements = showPageHTML.xpath("//a[@data-content-type=\"episode\"]")

            if episodeElements.count > 0 {
                // This is a series, so create a ProgrammeData for each episode.
                for episode in episodeElements {
                    processEpisodeElement(url: url, show: episode)
                }
            } else {
                // This page is itself a program (most likely a movie.)
                // Extract its metadata and create a ProgrammeData for it.
                processSingleEpisode(html: showPageHTML)
            }
        }
        
        seriesOperationCompleted()
    }

    func fetchEpisodeURLs() {
        self.episodeQueueSize = episodeURLs.count
        self.episodeQueueLeft = episodeQueueSize

        for episodeURL in episodeURLs {
                print("Starting request for \(episodeURL)")
                self.requestEpisodePage(url: episodeURL)
        }
    }

    func requestEpisodePage(url: URL) {

        mySession.dataTask(with: url) {(data, _, error) -> Void in
            print("Finished request for \(url)")

            guard let pageData = data, let pageSource = String(data: pageData, encoding: .utf8) else {
                self.episodeOperationCompleted()
                return
            }

            let show = ITVMetadataExtractor.getShowMetadata(htmlPageContent: pageSource)
            show.pid = url.lastPathComponent
            show.url = url.absoluteString
            self.episodes.append(show)
            self.episodeOperationCompleted()
        }.resume()
    }

    func writeEpisodeCacheFile() {
        self.logger?.add(toLog: "GetITVShows (Info): Episodes: \(episodes.count) Today Programmes: \(programmeURLs.count) ")
        
        /* Now create the cache file that used to be created by get_iplayer */
        //    my @cache_format = qw/index type name episode seriesnum episodenum pid channel available expires duration desc web thumbnail timeadded/;
        let cacheFileHeader = "#index|type|name|episode|seriesnum|episodenum|pid|channel|available|expires|duration|desc|web|thumbnail|timeadded\n"
        var cacheIndexNumber: Int = 100000
        let isoFormatter = DateFormatter()
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        isoFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        var cacheFileEntries = [String]()
        cacheFileEntries.append(cacheFileHeader)
        
        for episode in episodes {
            var cacheFileContentString = ""
            let dateAiredString = isoFormatter.string(from: episode.dateAired)

            let cachedEpisodeTitle: String
            if !episode.episodeName.isEmpty {
                cachedEpisodeTitle = episode.episodeName
            } else {
                cachedEpisodeTitle = DateFormatter.localizedString(from: episode.dateAired, dateStyle: .medium, timeStyle: .none)
            }

            let dateAddedInteger = Date().timeIntervalSince1970
            
            //    my @cache_format = qw/index type name episode seriesnum episodenum pid channel available expires duration desc web thumbnail timeadded/;
            cacheFileContentString += String(format: "%06d|", cacheIndexNumber)
            cacheIndexNumber += 1
            cacheFileContentString += "itv|"
            cacheFileContentString += episode.showName
            cacheFileContentString += "|"
            cacheFileContentString += cachedEpisodeTitle
            cacheFileContentString += "|\(episode.season)|\(episode.episode)|"
            cacheFileContentString += episode.pid
            cacheFileContentString += "|ITV Player|"
            cacheFileContentString += dateAiredString
            cacheFileContentString += "|||\(episode.desc)"
            cacheFileContentString += "|"
            cacheFileContentString += episode.url
            cacheFileContentString += "|"
            cacheFileContentString += episode.thumbnailURLString
            cacheFileContentString += "|\(Int(dateAddedInteger))|\n"
            cacheFileEntries.append(cacheFileContentString)
        }
        
        var cacheData = Data()
        for cacheString in cacheFileEntries {
            if let stringData = cacheString.data(using: .utf8) {
                cacheData.append(stringData)
            }
        }

        let cacheFilePath = supportPath("itv.cache")
        let fileManager = FileManager.default
        if !fileManager.createFile(atPath: cacheFilePath, contents: cacheData, attributes: nil) {
            showAlert(message: "GetITVShows: Could not create cache file!",
                      informative: "Please submit a bug report saying that the history file could not be created.")
        }

        endOfRun()
    }
    
    private func showAlert(message: String, informative: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = message
            alert.informativeText = informative
            alert.alertStyle = .warning
            alert.addButton(withTitle: "OK")
            alert.runModal()

        }
    }
    func endOfRun() {
        /* Notify finish and invaliate the NSURLSession */
        getITVShowRunning = false
        mySession.finishTasksAndInvalidate()
        NotificationCenter.default.post(name: NSNotification.Name("ITVUpdateFinished"), object: nil)
        self.logger?.add(toLog: "GetITVShows: Update Finished")
    }
    
}

