//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Víctor Ávila on 15/08/24.
//

import CodeScanner
import SwiftData
import SwiftUI

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
    
    @State private var isShowingScanner = false
    
    @State private var selectedProspects = Set<Prospect>() // By default, no selections.
    
    var body: some View {
        NavigationStack {
            List(prospects, selection: $selectedProspects) { prospect in // The selection is bound to selectedProspects
                VStack(alignment: .leading) {
                    Text(prospect.name)
                        .font(.headline)
                    
                    Text(prospect.emailAddress)
                        .foregroundStyle(.secondary)
                }
                .swipeActions {
                    // Swipe Actions don't play nicely with the .onDelete() modifier, so we've gotta make Delete work by hand:
                    // 1. We will add an individual swipe to delete like .onDelete();
                    // 2. We will also add a multiple selection option that let users remove multiple entries at the same time. This means adding an @State to store the active selection.
                    // We have to add the Delete Button first in the List so it becomes automatically attached to the full swipe to activate functionality, which is the default behavior.
                    Button("Delete", systemImage: "trash", role: .destructive) {// The destructive role is because this is a bad Button
                        modelContext.delete(prospect)
                        // Remember that the original Swipe to Delete shows the word "Delete" when swipping. However, Apple tells us to use only icons when having multiple options to choose.
                    }
                    
                    // We need a way to move people from the Uncontacted Tab to the Contacted Tab: we will add a Swipe Action to the VStack in ProspectView to do so.
                    // Since ProspectsView is shared between 3 Tabs, we've got to make sure the Swipe Action is correct no matter where they're used. The Ternary Operator approach will not work since we will add a separate Button. Instead, we will wrap our Buttons in a single condition.
                    if prospect.isContacted {
                        Button("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark") {
                            prospect.isContacted.toggle()
                        }
                        .tint(.blue) // Using blue since it is not deleting anything
                    } else {
                        Button("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark") {
                            // By calling .toggle() we flip the Bool, update the View and save the change to permanent storage
                            prospect.isContacted.toggle()
                        }
                        .tint(.green) // Using green since it is a "good" Button
                    }
                }
                // Helping SwiftUI to understand that this entire code is related to ONE prospect, add a Tag
                .tag(prospect) // When I am selected, I should add to the set or remove from the set the prospect object
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Scan", systemImage: "qrcode.viewfinder") {
                        isShowingScanner = true
                    }
                }
                
                // Showing an Edit/Done Button to allow selecting and deleting multiple entries. We will trigger the mass deletion with a second Button, located at the bottom of the screen just like Apple does.
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                
                // This will be shown only when there are selections available to delete
                if selectedProspects.isEmpty == false {
                    ToolbarItem(placement: .bottomBar) {
                        Button("Delete Selected", action: delete)
                    }
                }
            }
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr],
                                simulatedData: "Paul Hudson\npaul@hackingwithswift.com",
                                completion: handleScan)
            }
        }
    }
    
    init(filter: FilterType) {
        self.filter = filter
        
        if filter != .none {
            let showContactedOnly = filter == .contacted
            
            _prospects = Query(filter: #Predicate {
                $0.isContacted == showContactedOnly
            }, sort: [SortDescriptor(\Prospect.name)])
        }
    }
    
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            
            guard details.count == 2 else { return }
            
            let person = Prospect(name: details[0], emailAddress: details[1], isContacted: false)
            modelContext.insert(person)
            
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func delete() {
        // Looping over all selected prospects and deleting them
        for prospect in selectedProspects {
            modelContext.delete(prospect)
        }
    }
}

#Preview {
    ProspectsView(filter: .none)
        .modelContainer(for: Prospect.self)
}
