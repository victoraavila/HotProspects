//
//  MeView.swift
//  HotProspects
//
//  Created by Víctor Ávila on 15/08/24.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

// With a little more effort, we can make a functionality with which the user can share their QR Code outside the app.
// For this, we will use the ShareLink View, placing it inside a .contextMenu() modifier.

struct MeView: View {
    @AppStorage("name") private var name = "Anonymous"
    @AppStorage("emailAddress") private var emailAddress = "you@yoursite.com"
    
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    @State private var qrCode = UIImage()
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                    .textInputAutocapitalization(.never)
                    .textContentType(.name)
                    .font(.title)
                
                TextField("Email address", text: $emailAddress)
                    .textInputAutocapitalization(.never)
                    .textContentType(.emailAddress)
                    .font(.title)
                
                Image(uiImage: qrCode)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .contextMenu {
                        // Previously, it would make our UIImage by calling generateQRCode() again
                        
                        // We can't share UIImages, only SwiftUI's Images. Therefore, let's convert it
                        // This creates a Button in the Context Menu
                        ShareLink(item: Image(uiImage: qrCode), preview: SharePreview("My QR Code", image: Image(uiImage: qrCode)))
                        
                        // We could save part of the work by creating the QR Code only one time instead of twice (Caching)
                        // This is also problematic because we are passing in the same hardcoded String twice. In a situation where we have to change it, we would've got to remind to change it in both places
                        // We will do caching by creating a new @State property to store the UIImage that was made
                        
                        // Also, we've got to add the Permission Request asking to save the qrCode UIImage among the phone images
                        // Blue icon HotProspects > Targets > Info > Right click and choose Add Row > Privacy - Photo Library Additions Usage Description. Write "We want to save your QR code." in the Value column.
                        
                        // The code above causes a runtime issue: "Modifying state during view update, this will cause undefined behavior."
                        // This happens because the way our View is recursive: making the View body changes the QR Code, which makes the View body again and changes the QR Code... (the image is an @State property).
                        // The view is rendered, calling body.
                        // body calls generateQRCode(from:).
                        // generateQRCode(from:) modifies the qrCode @State property.
                        // Modifying qrCode triggers a view update.
                        // The view update causes body to be called again.
                        // The cycle repeats from step 2.
                        // To fix it, we have to make the Image View use our cached QR Code. However, we still have to call generateQRCode(from: "\(name)\n\(emailAddress)") somewhere, which will be along with .onAppear() and with .onChange(). This way, the QR Code will be updated when the View is first shown and when name or email address is changed. We will create an auxiliary method that will update our QR Code.
                    }
            }
            .navigationTitle("Your code")
            .onAppear(perform: updateCode)
            .onChange(of: name, updateCode)
            .onChange(of: emailAddress, updateCode)
        }
    }
    
    func updateCode() {
        qrCode = generateQRCode(from: "\(name)\n\(emailAddress)")
    }
    
    // This method now will implicitly make sure to update the @State property with the UIImage before sending it back
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}

#Preview {
    MeView()
}
