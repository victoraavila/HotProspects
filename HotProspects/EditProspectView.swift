//
//  EditProspectView.swift
//  HotProspects
//
//  Created by Víctor Ávila on 20/08/24.
//

import SwiftData
import SwiftUI

struct EditProspectView: View {
    @Bindable var prospect: Prospect
    
    var body: some View {
        Form {
            TextField("Name", text: $prospect.name)
                .textInputAutocapitalization(.never)
            TextField("Email address", text: $prospect.emailAddress)
                .textInputAutocapitalization(.never)
        }
        .navigationTitle("Change Prospect Details")
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Prospect.self, configurations: config)
    
    let prospect = Prospect(name: "Michael Jackson", emailAddress: "michael@gmail.com", isContacted: false, createdAt: Date.now)
    return EditProspectView(prospect: prospect).modelContainer(container)
}
