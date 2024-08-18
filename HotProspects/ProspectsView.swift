//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Víctor Ávila on 15/08/24.
//

// Scanning a QR Code or a Bar Code can be done with Apple's AVFoundation library. Since it does not work very well with SwiftUI, let's download Paul's CodeScanner: File > Add Package Dependencies... > https://github.com/twostraws/CodeScanner. Let Dependency Rule set to Up to Next Major Version and click Add Package.
// We will use the CodeScannerView, which will be shown inside a sheet and handle code in an isolated way.
// To start scanning QR Codes:
// 1. Add an @State property to track whether we are currently showing the scanning view or not.

// The CodeScanner package handles it all: it figures what the code is and how to send it back. All we gotta do is to catch the result and process it somehow. When it finds a code, it will a call a completion closure with a result instance containing details about the code found or an error saying what the problem was (for example, maybe the camera was not available or it could not scan codes).

// Before showing the scanner, we got to ask the user for permission to use their Camera. To do that, go to the HotProspects abstract > Targets > Info > Right click and choose Add Row > Privacy - Camera Usage Description. Add a message to be shown with the prompt by adding it on the Value column.

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
                    // Go ahead and show our Scanner
                    isShowingScanner = true
                }
            }
            .sheet(isPresented: $isShowingScanner) {
                // Creating a ScannerView takes at least 3 parameters:
                // 1. An Array of the types of codes we want to scan (iOS supports a lot of them);
                // 2. A String to use as simulated data (since we are in XCode and therefore we cannot use any real Camera), so CodeScanner can automatically present a replacement UI in this debug mode and return back this String;
                // 3. A completion function to use.
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
    
    
    func handleScan(result: Result<ScanResult, ScanError>) { // Result contains either a ScanResult or a ScanError
        isShowingScanner = false
        
        // The data we are passing back is a "name\nemail". So, if the scanning was successful, we can pull apart that code into those two components and create a new Prospect object from it. If the scanning fails, we will just put an error out.
        switch result {
        case .success(let result): // If it was successful, give me the result inside that
            let details = result.string.components(separatedBy: "\n")
            
            // We could scan a QR Code from a cereal box, for example. So, did we get exactly two pieces of information from that QR Code?
            guard details.count == 2 else { return }
            
            // Yay! We got exactly 2 pieces of information
            let person = Prospect(name: details[0], emailAddress: details[1], isContacted: false)
            modelContext.insert(person)
            
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ProspectsView(filter: .none)
        .modelContainer(for: Prospect.self)
}
