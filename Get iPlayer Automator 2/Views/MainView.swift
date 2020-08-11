//
//  MainView.swift
//  Get iPlayer Automator 3
//
//  Created by Scott Kovatch on 7/19/20.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var programCache: ProgramCache
    
    var body: some View {
        List(programCache.programs) { program in
            Text(program.series?.name ?? "None")
        }
        .listStyle(SidebarListStyle())
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(programCache: ProgramCache())
    }
}
