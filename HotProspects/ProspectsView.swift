//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Víctor Ávila on 15/08/24.
//

import SwiftUI

struct ProspectsView: View {
    // Since we are using 3 ProspectsView, we can customize each of them so they don't look identical.
    // We can represent all 3 situations: everyone, people you've already contacted and people you haven't contacted with an enum inside our ProspectsView.
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
    
    var body: some View {
        NavigationStack {
            Text("Hello, world!")
                .navigationTitle(title)
        }
    }
}

#Preview {
    // Every ProspectsView() initializer has to be called with a filter in place
    ProspectsView(filter: .none)
}
