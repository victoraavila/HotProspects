//
//  HotProspectsApp.swift
//  HotProspects
//
//  Created by Víctor Ávila on 15/08/24.
//

import SwiftData
import SwiftUI

@main
struct HotProspectsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Telling SwiftData to make a Model Container for Prospect, i.e., creating storage for the Prospect class and placing the shared SwiftData Model Context in every SwiftUI View
        .modelContainer(for: Prospect.self)
    }
}
