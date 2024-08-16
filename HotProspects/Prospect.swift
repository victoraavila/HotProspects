//
//  Prospect.swift
//  HotProspects
//
//  Created by Víctor Ávila on 15/08/24.
//

import SwiftData

// Defining a model to store one person we've met on our way

@Model
class Prospect {
    var name: String
    var emailAddress: String
    var isContacted: Bool
    
    // An initializer is mandatory
    // SwiftData's @Model macro can only be used on a class
    // This means we can share the same object in several Views and have them all kept up-to-date automatically
    init(name: String, emailAddress: String, isContacted: Bool) {
        self.name = name
        self.emailAddress = emailAddress
        self.isContacted = isContacted
    }
}
