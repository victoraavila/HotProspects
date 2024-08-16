//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Víctor Ávila on 15/08/24.
//

import SwiftData
import SwiftUI

// For the Everyone Tab: we want to get all entries and sort them by name.
// However, for the other Tabs, we're gonna need to add an initializer so we can override the default query when a filter is set.

struct ProspectsView: View {
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    let filter: FilterType
    
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
    
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Prospect.name) var prospects: [Prospect]
    
    var body: some View {
        NavigationStack {
            List(prospects) { prospect in
                VStack(alignment: .leading) {
                    Text(prospect.name)
                        .font(.headline)
                    
                    Text(prospect.emailAddress)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(title)
            .toolbar {
                Button("Scan", systemImage: "qrcode.viewfinder") {
                    let prospect = Prospect(name: "Paul Hudson", emailAddress: "paul@hackingwithswift.com", isContacted: false)
                    modelContext.insert(prospect)
                }
            }
        }
    }
    
    init(filter: FilterType) {
        self.filter = filter
        
        if filter != .none {
            // Then, we want to show either only contacted or non-contacted folks
            
            // If filter == .contacted, it will set showContactedOnly to true
            // Otherwise, it will set showContactedOnly to false
            let showContactedOnly = filter == .contacted
            
            _prospects = Query(filter: #Predicate {
                // If the current row have isContacted set to true and showContactedOnly is also set to true, keep the row
                $0.isContacted == showContactedOnly
            }, sort: [SortDescriptor(\Prospect.name)])
        }
        
        // With this initializer, we can now create a List to just loop over all the results in the resulting Array, and show for each of them both a title and their e-mail address using a VStack.
    }
}

#Preview {
    ProspectsView(filter: .none)
        .modelContainer(for: Prospect.self)
}
