//
//  main.swift
//  Search testing
//
//  Created by Scott Kovatch on 8/7/20.
//  Copyright © 2020 Ascoware LLC. All rights reserved.
//

import Foundation


let terms = ["Doctor Who"]
let search = GIASearch(searchTerms: terms, allowHiding: false, logger: TestLogger())
baseLocation = URL(fileURLWithPath: "/Users/skovatch/src/get-iplayer-automator/Binaries", isDirectory: true)
search.start()
print ("Found \(search.searchResults.count) items")
search.searchResults.forEach {
    print($0)
}

