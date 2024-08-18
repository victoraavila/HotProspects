//
//  MeView.swift
//  HotProspects
//
//  Created by Víctor Ávila on 15/08/24.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

// CoreImage lets us generate a QR Code from any input String and does so extremely quickly
// However, there is a problem: the generated image is very small, because it is only as big as the pixels required to show its data
// It is trivial to make it larger, but to make it look good we have to adjust SwiftUI's image interpolation
// We will ask the user to enter the name and email address into a Form, and then use this information to make a QR Code identifying them. Afterwards, we will scale it up without making it fuzzy.

struct MeView: View {
    // Let's add new @State properties to hold the name and email address
    @AppStorage("name") private var name = "Anonymous"
    @AppStorage("emailAddress") private var emailAddress = "you@yoursite.com"
    
    // CoreImage has a filter for QR Code generation built in.
    // 1. Import CoreImage.CIFilterBuiltins
    // 2. Create 2 properties: the first will store an active CoreImage Context, and the other will store an instance of CoreImage's QR Code Generator filter.
    // Working with CoreImage filters requires to provide some kind of input data, then convert the output CIImage into a CGImage and then the CGImage into an UIImage.
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var body: some View {
        // 2 TextFields with large fonts with .textContentType(), which tells iOS what kind of information we're asking the user for (and therefore enables iOS to autocomplete data on behalf of the user)
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                    .textContentType(.name)
                    .font(.title)
                
                TextField("Email address", text: $emailAddress)
                    .textContentType(.emailAddress)
                    .font(.title)
                
                // SwiftUI will make sure generateQRCode() gets called whenever name or emailAddress changes.
                // The String passed in will be the name and email address entered by the user separated by a line break, which is easy to revert when scanning.
                Image(uiImage: generateQRCode(from: "\(name)\n\(emailAddress)"))
                    // SwiftUI will try to smooth out the pixels as it's being scaled. However, line art like QR Codes and Bar Codes are great candidates for disabling image interpolation. This way, SwiftUI will repeat pixels instead of trying to blend them together.
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            .navigationTitle("Your code") // Since this is their personal QR Code
        }
    }
    
    // The filter expects a Data as input, but our input is a String, so we need to convert that.
    // If conversion fails for any reason, we will send back a SF Symbol "xmark.circle". If the SF Symbol can't be read (which can happen, since it is a String), we'll send back an empty UIImage.
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8) // The message is the String we will store in our QR Code.
        
        // Trying to read our data
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) { // Convert the whole image to our CGImage
                // If we can read the output and load it correctly
                return UIImage(cgImage: cgImage)
            }
        }
        
        // This return is only reached if we can't read the output or we can't load it correctly
        // In practice, since we hardcoded the SF Symbol name, it won't fail
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

#Preview {
    MeView()
}
