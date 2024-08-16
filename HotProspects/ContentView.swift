//
//  ContentView.swift
//  HotProspects
//
//  Created by Víctor Ávila on 15/08/24.
//

import SwiftUI

// Most of the time it takes little work to get SwiftData set up
// We want all 3 instances of ProspectsView to share the same data, but have different Views on it, i.e., they will all access the same Model Context using different queries.

struct ContentView: View {
    var body: some View {
        TabView {
            ProspectsView(filter: .none)
                .tabItem {
                    Label("Everyone", systemImage: "person.3")
                }
            
            ProspectsView(filter: .contacted)
                .tabItem {
                    Label("Contacted", systemImage: "checkmark.circle")
                }
            
            ProspectsView(filter: .uncontacted)
                .tabItem {
                    Label("Uncontacted", systemImage: "questionmark.diamond")
                }
            
            MeView()
                .tabItem {
                    Label("Me", systemImage: "person.crop.square")
                }
        }
    }
}

#Preview {
    ContentView()
}
