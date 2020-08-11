
import Foundation
import Cocoa
import Kanna

public class ITVPrograms: NSObject, URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    var myQueueSize: Int = 0
    var myQueueLeft: Int = 0
    var mySession: URLSession?
    
    var programmes = [Program]()
    var episodes = [Program]()
    var getITVShowRunning = false
    let currentTime = Date()
    let logger: Logging
    var myOpQueue = OperationQueue()
    
    var programmesFilePath: URL? {
        return supportPath("itvprograms.gia")
    }

    init(logger: Logging) {
        self.logger = logger
    }
    
    func supportPath(_ fileName: String) -> URL? {
        return FileManager.default.applicationSupportDirectory.appendingPathComponent(fileName)
    }
    
    public func itvUpdate() {
        /* cant run if we are already running */
        if getITVShowRunning == true {
            return
        }

        logger.addToLog("GetITVShows: ITV Cache Update Starting ")
        
        getITVShowRunning = true
        myQueueSize = 0
        episodes = []
        
        /* Create the NUSRLSession */
        let defaultConfigObject = URLSessionConfiguration.default
        let cachePath: String = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("/itvloader.cache").path
        let myCache = URLCache(memoryCapacity: 16384, diskCapacity: 268435456, diskPath: cachePath)
        defaultConfigObject.urlCache = myCache
        defaultConfigObject.requestCachePolicy = .useProtocolCachePolicy
        defaultConfigObject.timeoutIntervalForResource = 30
        defaultConfigObject.timeoutIntervalForRequest = 30
        mySession = URLSession(configuration: defaultConfigObject, delegate: self, delegateQueue: OperationQueue.main)
        
        /* Load in all shows for itv.com */
        myOpQueue.maxConcurrentOperationCount = 1
        
        if let aString = URL(string: "https://www.itv.com/hub/shows") {
            mySession?.dataTask(with: aString) {(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void in
                if let error = error {
                    let errorMessage = "GetITVListings (Error: \(error.localizedDescription)): Unable to retreive show listings from ITV"
                    self.logger.addToLog(errorMessage)
                }
                
                guard let data = data else {
                    self.endOfRun()
                    return
                }
                
                if self.createProgrammes(data: data) {
                    self.myQueueSize = self.programmes.count
                    self.myQueueLeft = self.myQueueSize
                    
                    if self.myQueueSize >= 0 {
                        for todayProgramme in self.programmes {
                            self.myOpQueue.addOperation {
                                self.requestProgrammeEpisodes(todayProgramme)
                            }
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
        programmes.removeAll()
        
        if let showsPage = try? HTML(html: data, encoding: .utf8) {
            let shows = showsPage.xpath("//a[@class='complex-link']")
            
            for show in shows {
                guard let showPage = show.at_xpath("@href")?.text,
                    let showPageURL = URL(string: showPage) else {
                        continue
                }
                
                let showName: String?
                let numberEpisodes: Int
                let productionID: String?
                let showPageURLString: String?
                
                showPageURLString = showPage
                productionID = showPageURL.lastPathComponent
                
                showName = show.at_xpath(".//h3[@class='tout__title complex-link__target theme__target']")?.content?.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if let numberEpisodesString = show.at_xpath(".//p[@class='tout__meta theme__meta']")?.content?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    let scanner = Scanner(string: numberEpisodesString)
                    numberEpisodes = scanner.scanInt() ?? 0
                } else {
                    numberEpisodes = 0
                }
                
                if numberEpisodes > 0 {
                    // Check for duplicate show listings.
                    let existingProgram = programmes.filter { $0.pid == productionID }
                    
                    if existingProgram.count == 0 {
                        let myProgramme = Program()
                        myProgramme.title = showName ?? "<None>"
                        myProgramme.pid = productionID ?? ""
                        myProgramme.url = showPageURLString ?? ""
                        myProgramme.episodeCount = numberEpisodes
                        myProgramme.lastBroadcast = currentTime
                        myProgramme.summary = ""
                        myProgramme.thumbnailURL = ""
                        programmes.append(myProgramme)
                    }
                }
            }
        }
        
        /* Now we sort the programmes and drop the duplicates */
        if programmes.count == 0 {
            logger.addToLog("No programmes found on www.itv.com/hub/shows")
            showAlert(message: "No programmes were found on www.itv.com/hub/shows",
                      informative: "Try again later. If the problem persists please file a bug.")
            return false
        }
        
        programmes.sort { $0.title < $1.title }
        return true
    }
    
    func requestProgrammeEpisodes(_ myProgramme: Program) {
        /* Get all episodes for the programme name identified in MyProgramme */
        if let url = URL(string: myProgramme.url) {
            mySession?.dataTask(with: url) {(data, _, error) in
                self.processEpisodesForProgram(myProgramme, pageData: data, error: error)
            }.resume()
        }
    }
    
    func dateForTimeString(_ time:String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
        dateFormatter.timeZone = TimeZone(secondsFromGMT:0)
        return dateFormatter.date(from: time)
    }
    
    func processEpisodeElement(program: Program, show: Kanna.XMLElement) {
        let dateTimeString = show.at_xpath(".//@datetime")?.text
        
        var dateAiredUTC: Date? = nil
        if let dateTimeString = dateTimeString {
            dateAiredUTC = dateForTimeString(dateTimeString)
        }
        
        let programURL = URL(string: program.url)?.deletingLastPathComponent()
        
        let description = show.at_xpath(".//p[@class='tout__summary theme__subtle']")?.content?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var episodeNumber: Int? = 0
        if let episode = show.at_xpath(".//h3[@class='tout__title complex-link__target theme__target ']")?.content?.trimmingCharacters(in: .whitespacesAndNewlines) {
            let episodeScanner = Scanner(string: episode)
            _ = episodeScanner.scanString("Episode ")
            episodeNumber = episodeScanner.scanInt()
        }
        
        var seriesNumber: Int? = 0
        if let series = show.at_xpath(".//h2[@class='module__heading']")?.content?.trimmingCharacters(in: .whitespacesAndNewlines) {
            let seriesScanner = Scanner(string: series)
            _ = seriesScanner.scanString("Series ")
            seriesNumber = seriesScanner.scanInt()
        }
        
        var productionID: String? = ""
        var showURL: URL? = nil
        if let showURLString = show.at_xpath("@href")?.text {
            showURL = URL(string: showURLString)
            productionID = showURL?.lastPathComponent
        }
        
        //        print("Program: \(program.programmeName)")
        //        print("Show URL: \(showURL?.absoluteString ?? "")")
        //        print("Episode number: \(episodeNumber ?? 0)")
        //        print("Series number: \(seriesNumber ?? 0)")
        //        print("productionID: \(productionID ?? "")")
        //        print("Date aired: \(dateTimeString ?? "Unknown")")
        //        print("=================")
        
        // Make sure the URL matches the show listing -- ITV likes to sneak other shows on a program page.
        if let showURLBase = showURL?.deletingLastPathComponent(), showURLBase.absoluteString == programURL?.absoluteString {
            
            /* Create Program Object and store in array */
            let p = Program()
            p.title = program.title
            p.pid = productionID ?? ""
            p.url = showURL?.absoluteString ?? ""
            p.episodeCount = program.episodeCount
            p.lastBroadcast = dateAiredUTC
            p.season = seriesNumber ?? 0
            p.summary = description ?? ""
            p.episode = episodeNumber ?? 0
            self.episodes.append(p)
        }
        
    }
    
    func processSingleEpisode(_ aProgramme: Program, html: HTMLDocument) {
        let showDataElement = html.xpath("//script[@id=\"json-ld\"]")
        
        if let nodeContent = showDataElement.first?.text {
            let data = nodeContent.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
                if let description = json["description"] as? String {
                    aProgramme.summary = description
                }
                
                if let url = json["@id"] as? String {
                    aProgramme.url = url
                    aProgramme.pid = URL(string: url)?.lastPathComponent ?? ""
                }
                
                if let showName = json["partOfSeries"]?["name"] as? String {
                    aProgramme.title = showName
                }
                
                if let thumbnailURL = json["image"]?["url"] as? String {
                    aProgramme.thumbnailURL = thumbnailURL
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
        
        if let dateElement = html.at_xpath(".//li[@class='episode-info__meta-item episode-info__meta-item--broadcast']") {
            if let dateTimeElement = dateElement.at_xpath(".//@datetime")?.text {
                aProgramme.lastBroadcast = dateForTimeString(dateTimeElement)
            }
        }
        
        self.episodes.append(aProgramme)
    }
    
    fileprivate func operationCompleted() {
        let increment = Double(myQueueSize - 1) > 0 ? 100.0 / Double(myQueueSize - 1) : 100.0
        // TODO!!!!!!! AppController.shared().itvProgressIndicator.increment(by: increment)
        
        /* Check if there is any outstanding work before processing the carried forward programme list */
        myQueueLeft -= 1
        if (myQueueLeft == 0) {
            writeEpisodeCacheFile()
        }
    }
    
    func processEpisodesForProgram(_ aProgramme: Program, pageData: Data?, error: Error?) {
        if let error = error {
            let errorMessage = "GetITVListings (Error(\(error))): Unable to retreive programme episodes for \(aProgramme.url)"
            logger.addToLog(errorMessage)
            operationCompleted()
            return
        }
        
        guard let pageData = pageData else {
            operationCompleted()
            return
        }
        
        if let showPageHTML = try? HTML(html: pageData, encoding: .utf8) {
            let episodeElements = showPageHTML.xpath("//a[@data-content-type=\"episode\"]")
            
            if episodeElements.count > 0 {
                // This is a series, so create a Program for each episode.
                for episode in episodeElements {
                    processEpisodeElement(program: aProgramme, show: episode)
                }
            } else {
                // This page is itself a program (most likely a movie.)
                // Extract its metadata and create a Program for it.
                processSingleEpisode(aProgramme, html: showPageHTML)
            }
        }
        
        operationCompleted()
    }
    
    func writeEpisodeCacheFile() {
        logger.addToLog("GetITVShows (Info): Episodes: \(episodes.count) Today Programmes: \(programmes.count) ")
        
        /* First we update datetimeadded for the carried forward programmes */
        for programme: Program in episodes {
            programme.timeAdded = currentTime
        }
        
        /* Now write CF to disk */
        if let path = programmesFilePath {
            do {
                let archivedData = try NSKeyedArchiver.archivedData(withRootObject: episodes, requiringSecureCoding: false)
                try archivedData.write(to: path)
            } catch {
                // help?
            }
        }
        
        /* Now create the cache file that used to be created by get_iplayer */
        //    my @cache_format = qw/index type name episode seriesnum episodenum pid channel available expires duration desc web thumbnail timeadded/;
        let cacheFileHeader = "#index|type|name|episode|seriesnum|episodenum|pid|channel|available|expires|duration|desc|web|thumbnail|timeadded\n"
        var cacheIndexNumber: Int = 100000
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE MMM dd"
        var episodeString: String? = nil
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        dateFormatter1.timeZone = TimeZone(secondsFromGMT: 0)
        var dateAiredString: String? = nil
        var cacheFileEntries = [String]()
        cacheFileEntries.append(cacheFileHeader)
        
        for episode: Program in episodes {
            var cacheFileContentString = ""
            if let timeDateLastAired = episode.lastBroadcast {
                episodeString = dateFormatter.string(from: timeDateLastAired)
                dateAiredString = dateFormatter1.string(from: timeDateLastAired)
            } else {
                episodeString = ""
                dateAiredString = dateFormatter1.string(from: Date())
            }
            
            let dateAddedInteger = episode.timeAdded.timeIntervalSince1970
            
            //    my @cache_format = qw/index type name episode seriesnum episodenum pid channel available expires duration desc web thumbnail timeadded/;
            cacheFileContentString += String(format: "%06d|", cacheIndexNumber)
            cacheIndexNumber += 1
            cacheFileContentString += "itv|"
            cacheFileContentString += episode.title
            cacheFileContentString += "|"
            
            if let aString = episodeString {
                cacheFileContentString += aString
            }
            
            cacheFileContentString += "|\(episode.season)|\(episode.episode)|"
            cacheFileContentString += episode.pid
            cacheFileContentString += "|ITV Player|"
            if let aString = dateAiredString {
                cacheFileContentString += aString
            }
            
            cacheFileContentString += "|||\(episode.description)"
            cacheFileContentString += "|"
            cacheFileContentString += episode.url
            cacheFileContentString += "||\(Int(dateAddedInteger))|\n"
            cacheFileEntries.append(cacheFileContentString)
        }
        
        var cacheData = Data()
        for cacheString in cacheFileEntries {
            if let stringData = cacheString.data(using: .utf8) {
                cacheData.append(stringData)
            }
        }
        
        let cacheFile = supportPath("itv.cache")
        let fileManager = FileManager.default
        if let cacheFilePath = cacheFile?.absoluteString {
            if !fileManager.createFile(atPath: cacheFilePath, contents: cacheData, attributes: nil) {
                showAlert(message: "GetITVShows: Could not create cache file!",
                          informative: "Please submit a bug report saying that the history file could not be created.")
            }
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
        mySession?.finishTasksAndInvalidate()
        NotificationCenter.default.post(name: NSNotification.Name("ITVUpdateFinished"), object: nil)
        logger.addToLog("GetITVShows: Update Finished")
    }
    
}

