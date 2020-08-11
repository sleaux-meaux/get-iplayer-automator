//
//  FileManager+DirectoryLocations.swift
//  Get iPlayer Automator 3
//
//  Created by Scott Kovatch on 7/19/20.
//

import Foundation

public extension FileManager {
    
    
    //
    // findOrCreateDirectory:inDomain:appendPathComponent:error:
    //
    // Method to tie together the steps of:
    //    1) Locate a standard directory by search path and domain mask
    //  2) Select the first path in the results
    //    3) Append a subdirectory to that path
    //    4) Create the directory and intermediate directories if needed
    //    5) Handle errors by emitting a proper NSError object
    //
    // Parameters:
    //    searchPathDirectory - the search path passed to NSSearchPathForDirectoriesInDomains
    //    domainMask - the domain mask passed to NSSearchPathForDirectoriesInDomains
    //    appendComponent - the subdirectory appended
    //    errorOut - any error from file operations
    //
    // returns the path to the directory (if path found and exists), nil otherwise
    //
    func findOrCreateDirectory(searchPathDirectory: FileManager.SearchPathDirectory,
                                      inDomain domainMask:FileManager.SearchPathDomainMask,
                                      appendPathComponent: String?) -> URL? {
        //
        // Search for the path
        //
        let paths = FileManager.default.urls(for: searchPathDirectory, in: domainMask)
        if paths.count == 0 {
            print("No path found for directory in domain.")
            return nil
        }
    
        //
        // Normally only need the first path returned
        //
        let resolvedPath: URL
        if let appendPathComponent = appendPathComponent {
            resolvedPath = paths[0].appendingPathComponent(appendPathComponent)
        } else {
            resolvedPath = paths[0]
        }
        
        //
        // Create the path if it doesn't exist
        //
        do {
            try createDirectory(at: resolvedPath, withIntermediateDirectories: true)
        } catch {
            return nil
        }
        
        return resolvedPath;
    }

    var applicationSupportDirectory: URL {

        let executableName = Bundle.main.object(forInfoDictionaryKey:"CFBundleExecutable") as? String ?? "Get iPlayer Automator"
        
        guard let result = findOrCreateDirectory(searchPathDirectory: SearchPathDirectory.applicationSupportDirectory,
                                           inDomain: SearchPathDomainMask.userDomainMask,
                                           appendPathComponent: executableName) else {
            print("Unable to find or create application support directory, returning default.")
            return URL(fileURLWithPath: NSHomeDirectory())
                .appendingPathComponent(".get_iplayer")
        }

        return result
    }
}
