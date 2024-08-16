//
//  ContentView.swift
//  HotProspects
//
//  Created by Víctor Ávila on 15/08/24.
//

import SwiftUI

// The Tab Bar will have 4 SwiftUI Views:
// 1. One to show everyone you've met;
// 2. One to show people you've contacted;
// 3. One to show people you haven't contacted yet;
// 4. One to show your personal information for others to scan.
// The first three are variations of the same concept, but the last one is different.
// We can represent our UI with just 3 Views: one to display people, one to show data and one to bring the others together using the TabView.
// Let's make placeholder Views for our Tabs, so we can fill them later on.
// We will store our TabView here in ContentView. For now, it will just be a TabView with 3 instances of ProspectsView and 1 instance of MeView, each having a .tabItem() modifier with an SF Symbols Image and some Text.

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
