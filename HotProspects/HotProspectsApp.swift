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
        .modelContainer(for: Prospect.self)
    }
}
