//
//  Preferences.swift
//  Get iPlayer Automator 2
//
//  Created by Scott Kovatch on 8/8/20.
//  Copyright © 2020 Ascoware LLC. All rights reserved.
//

import Foundation

public class Preferences {

    static func resetDefaults() {
        var defaultDownloadDirectory = NSHomeDirectory()

        if let tvShowsDir = FileManager.default.findOrCreateDirectory(searchPathDirectory: .moviesDirectory,
                                                                      inDomain: .userDomainMask,
                                                                      appendPathComponent: "TV Shows") {
            defaultDownloadDirectory = tvShowsDir.path
        }

        //Register Default Preferences
        var defaultValues = Dictionary<String, Any>()

        defaultValues["DownloadPath"] = defaultDownloadDirectory;
        defaultValues["Proxy"] = "None";
        defaultValues["CustomProxy"] = "";
        defaultValues["AutoRetryFailed"] = true;
        defaultValues["AutoRetryTime"] = "30";
        defaultValues["AddCompletedToiTunes"] = true;
        defaultValues["DefaultBrowser"] = "Safari";
        defaultValues["CacheBBC_TV"] = true;
        defaultValues["CacheITV_TV"] = true;
        defaultValues["CacheBBC_Radio"] = false;
        defaultValues["CacheExpiryTime"] = "4";
        defaultValues["Verbose"] = false;
        defaultValues["SeriesLinkStartup"] = true;
        defaultValues["DownloadSubtitles"] = false;
        defaultValues["EmbedSubtitles"] = true;
        defaultValues["AlwaysUseProxy"] = false;
        defaultValues["XBMC_naming"] = false;
        defaultValues["KeepSeriesFor"] = "30";
        defaultValues["RemoveOldSeries"] = false;
        defaultValues["TagShows"] = true;
        defaultValues["TagRadioAsPodcast"] = false;
        defaultValues["BBCOne"] = true;
        defaultValues["BBCTwo"] = true;
        defaultValues["BBCFour"] = true;
        defaultValues["CBBC"] = false;
        defaultValues["CBeebies"] = false;
        defaultValues["BBCNews"] = false;
        defaultValues["BBCParliament"] = false;
        defaultValues["Radio1"] = true;
        defaultValues["Radio2"] = true;
        defaultValues["Radio3"] = true;
        defaultValues["Radio4"] = true;
        defaultValues["Radio4Extra"] = true;
        defaultValues["Radio6Music"] = true;
        defaultValues["BBCWorldService"] = false;
        defaultValues["Radio5Live"] = false;
        defaultValues["Radio5LiveSportsExtra"] = false;
        defaultValues["Radio1Xtra"] = false;
        defaultValues["RadioAsianNetwork"] = false;
        defaultValues["ShowRegionalRadioStations"] = false;
        defaultValues["ShowLocalRadioStations"] = false;
        defaultValues["ShowRegionalTVStations"] = false;
        defaultValues["ShowLocalTVStations"] = false;
        defaultValues["IgnoreAllTVNews"] = true;
        defaultValues["IgnoreAllRadioNews"] = true;
        defaultValues["ShowBBCTV"] = true;
        defaultValues["ShowBBCRadio"] = true;
        defaultValues["ShowITV"] = true;
        defaultValues["TestProxy"] = true;
        defaultValues["ShowDownloadedInSearch"] = true;
        defaultValues["AudioDescribedNew"] = false;
        defaultValues["SignedNew"] = false;
        defaultValues["Use25FPSStreams"] = false;

        let stdDefaults = UserDefaults.standard

        stdDefaults.register(defaults: defaultValues)

        //Migrate old AudioDescribed option
        if stdDefaults.object(forKey: "AudioDescribed") != nil {
            stdDefaults.set(true, forKey:"AudioDescribedNew")
            stdDefaults.set(true, forKey:"SignedNew")
            stdDefaults.removeObject(forKey: "AudioDescribed")
        }

        // Migrate Regionals
        if let bbcAlba = stdDefaults.object(forKey: "BBCAlba") as? Bool, bbcAlba, let s4c = stdDefaults.object(forKey:"S4C") as? Bool, s4c {
            stdDefaults.set(true, forKey:"ShowRegionalTVStations")
            stdDefaults.removeObject(forKey:"BBCAlba")
            stdDefaults.removeObject(forKey:"S4C")
        }
    }
}
