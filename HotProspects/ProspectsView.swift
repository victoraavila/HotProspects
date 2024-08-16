//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Víctor Ávila on 15/08/24.
//

import SwiftData
import SwiftUI

struct ProspectsView: View {
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    let filter: FilterType
    
    // The title will depend on which of the 3 ProspectsView this one is
    var title: String {
        switch filter {
        case .none:
            "Everyone"
        case .contacted:
            "Contacted people"
        case .uncontacted:
            "Uncontacted people"
        }
    }
    
    // Since we want all ProspectsView to share the same model data, we need to add 2 properties:
    // 1. One to access the Model Context;
    // 2. Another to form a query for Prospect objects.
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Prospect.name) var prospects: [Prospect]
    
    var body: some View {
        NavigationStack {
            Text("People: \(prospects.count)")
                .navigationTitle(title)
            
                // Adding a simple Navigation Bar Item that just adds test data and shows it on screen
                // Since they share the same instance of Prospect, the entry will be added to all 3 ProspectsViews.
                .toolbar {
                    Button("Scan", systemImage: "qrcode.viewfinder") {
                        let prospect = Prospect(name: "Paul Hudson", emailAddress: "paul@hackingwithswift.com", isContacted: false)
                        modelContext.insert(prospect)
                    }
                }
        }
    }
}

#Preview {
    // Every ProspectsView() initializer has to be called with a filter in place
    ProspectsView(filter: .none)
    
        // Adding a Model Container in order to use XCode's Canvas Preview
        .modelContainer(for: Prospect.self)
}
