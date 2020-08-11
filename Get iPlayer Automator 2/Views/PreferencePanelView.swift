//
//  PreferencePanelView.swift
//  Get iPlayer Automator 2
//
//  Created by Scott Kovatch on 8/8/20.
//  Copyright © 2020 Ascoware LLC. All rights reserved.
//

import SwiftUI

struct PreferencePanelView: View {
    //    var prefs: Preferences
    @State var bbcOne = false
    @State var bbcTwo = false
    @State var bbcFour = false
    @State var includeDownloaded = false

    var body: some View {
        TabView {
            VStack {
                HStack {
                    GroupBox(label: Text("BBC TV Channels")) {
                        List {
                            Toggle(isOn: $bbcOne) {
                                Text("BBC One")
                            }
                            Toggle(isOn: $bbcTwo) {
                                Text("BBC Two")
                            }
                            Toggle(isOn: $bbcFour) {
                                Text("BBC Four")
                            }
                            Toggle(isOn: $bbcOne) {
                                Text("BBC News")
                            }
                            Toggle(isOn: $bbcTwo) {
                                Text("BBC Parliament")
                            }
                            Toggle(isOn: $bbcFour) {
                                Text("CBBC")
                            }
                            Toggle(isOn: $bbcFour) {
                                Text("CBeebies")
                            }
                        }

                        HStack {
                            VStack(alignment: .leading) {
                                Toggle(isOn: $bbcOne) {
                                    Text("Show Regional TV Stations")
                                }
                                Toggle(isOn: $bbcTwo) {
                                    Text("Show Local TV Stations")
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 5))
                    GroupBox(label: Text("BBC Radio Stations")) {
                        List {
                            Toggle(isOn: $bbcOne) {
                                Text("BBC Radio 1")
                            }
                            Toggle(isOn: $bbcTwo) {
                                Text("BBC Radio 2")
                            }
                            Toggle(isOn: $bbcFour) {
                                Text("BBC Radio 3")
                            }
                            Toggle(isOn: $bbcOne) {
                                Text("BBC Radio 4")
                            }
                            Toggle(isOn: $bbcTwo) {
                                Text("BBC Radio 4 EXtra")
                            }
                            Group {
                                Toggle(isOn: $bbcFour) {
                                    Text("6 Music")
                                }
                                Toggle(isOn: $bbcFour) {
                                    Text("BBC World Service")
                                }
                                Toggle(isOn: $bbcFour) {
                                    Text("BBC Radio 5 Live")
                                }
                                Toggle(isOn: $bbcFour) {
                                    Text("BBC Radio 1Xtra")
                                }
                                Toggle(isOn: $bbcFour) {
                                    Text("BBC Radio 5 Live Sports Extra")
                                }
                                Toggle(isOn: $bbcFour) {
                                    Text("BBC Radio Asian Network")
                                }
                            }
                        }
                        HStack {
                            VStack(alignment: .leading) {
                                Toggle(isOn: $bbcOne) {
                                    Text("Show Regional Radio Stations")
                                }
                                Toggle(isOn: $bbcTwo) {
                                    Text("Show Local Radio Stations")
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 10))
                }
                GroupBox(label: Text("News Programs")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Toggle(isOn: $bbcOne) {
                                Text("Ignore TV programmes with 'news' in the title")
                            }
                            Toggle(isOn: $bbcTwo) {
                                Text("Ignore Radio programmes with 'news' in the title")
                            }
                        }
                        //                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        Spacer()
                    }
                }
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            }
            .tabItem {
                Text("General")
            }
            Text("Another Tab")
                .tabItem {
                    Text("Download Formats")
            }
            Text("Advanced")
                .tabItem {
                    Text("New Programs")
            }
            Text("Advanced")
                .tabItem {
                    Text("Advanced")
            }
        }
    }

}

struct PreferencePanelView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencePanelView()
            .frame(width: 600, height: 400)
    }
}
