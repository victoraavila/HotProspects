//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Víctor Ávila on 15/08/24.
//

import CodeScanner
import SwiftData
import SwiftUI

// We will add another Button to our list of Swipe Actions letting users opt to be reminded to contact a particular person
// This will use UserNotifications to make a new local notification and will be conditionally included in between the Swipe Actions (shown only if the user hasn't been contacted already).
// To schedule this notification in the first time, we have to request for authorization to show notifications on the Lock Screen. We have to be careful to handle the situation in which the user has disabled the permission afterwards. For this, we could call requestNotification() every time we want to post a notification. In the first time, an alert will be shown. In all other times, it will immediately return success or failure based on the previous response.
// However, we will act differently: we will request getNotificationSettings() and use that to determine whether to make a new notification or to request permission. The settings object gives us properties, such as an alert setting to check whether we can show an alert or not (if not, we can only display the red badge). If the new permission was successfully accepted, then we will also show a notification.
// We will create a closure to schedule a notification and use it in all successful cases.
import UserNotifications

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
    
    @State private var selectedProspects = Set<Prospect>()
    
    var body: some View {
        NavigationStack {
            List(prospects, selection: $selectedProspects) { prospect in
                HStack {
                    VStack(alignment: .leading) {
                        Text(prospect.name)
                            .font(.headline)
                        
                        Text(prospect.emailAddress)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if filter == .none {
                        Image(systemName: prospect.isContacted ? "person.crop.circle.fill.badge.checkmark" : "person.crop.circle.badge.xmark")
                            .font(.title)
                            .foregroundStyle(prospect.isContacted ? .green : .red)
                    }
                }
                .swipeActions {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        modelContext.delete(prospect)
                    }
                    
                    if prospect.isContacted {
                        Button("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark") {
                            prospect.isContacted.toggle()
                        }
                        .tint(.blue)
                    } else {
                        Button("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark") {
                            prospect.isContacted.toggle()
                        }
                        .tint(.green)
                        
                        // Adding an extra Button for scheduling a notification to contact
                        // This particular Button should only appear for prospects which are currently not contacted
                        Button("Remind Me", systemImage: "bell") {
                            addNotification(for: prospect)
                        }
                        .tint(.orange)
                    }
                }
                .tag(prospect)
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Scan", systemImage: "qrcode.viewfinder") {
                        isShowingScanner = true
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }
                
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
        for prospect in selectedProspects {
            modelContext.delete(prospect)
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        // A closure which we can call whenever we need in the future
        // This closure will be called in all successful scenarios and is responsible for creating a notification for the current prospect
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            // Defining when to show the notification
//            var dateComponents = DateComponents()
//            dateComponents.hour = 9 // Showing it at 9 a.m.
//            
//            // We have to use UNCalendarNotificationTrigger since we are defining a datetime target
//            // Don't repeat it every day, just once
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            // Uncomment this for testing purposes, so it will trigger after 5 seconds elapsed
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            // The identifier is a random identifier
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        // Using getNotificationSettings() and requestAuthorization() to make sure we only schedule notification when we are allowed to
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                // Below, options is what we want to show on the screen
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    // If the authorization was just granted
                    if success {
                        addRequest()
                    } else if let error {
                        print(error.localizedDescription) // This will print "The user denied" or something like it
                    }
                }
            }
        }
    }
}

#Preview {
    ProspectsView(filter: .none)
        .modelContainer(for: Prospect.self)
}
