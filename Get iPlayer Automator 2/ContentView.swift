//
//  ContentView.swift
//  Get iPlayer Automator 2
//
//  Created by Scott Kovatch on 11/8/19.
//  Copyright © 2019 Ascoware LLC. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack {
            Text("Show")
            Text("Episode")
            Text("Last broadcast")
            Button("Info", action: {
                // show info panel
            })
            Text("Network")
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
