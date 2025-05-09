//
//  ProfileEditView.swift
//  Textie
//
//  Created by 하정우 on 4/30/25.
//

import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @Binding var profile: UserProfile
    
    @Environment(\.dismiss) private var dismiss
    
    @State var selectedImage: PhotosPickerItem?
    
    var dateRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
        let max = Date()
        return min...max
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }.padding()
            List {
                HStack {
                    Text("Profile Picture")
                    Spacer()
                    PhotosPicker(selection: $selectedImage, matching: .images, preferredItemEncoding: .automatic) {
                        ProfileImageView(imageURL: profile.profileImageURL)
                                .frame(width: 80, height: 80)
                                .padding()
                    }
                    .onDisappear {
                        if let selectedImage = selectedImage {
                            // TODO: implement image change code
                        }
                    }
                }
                
                HStack {
                    Text("Name")
                    Spacer()
                    TextField("Name", text:$profile.name)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                }
                
                HStack {
                    Text("User ID")
                    Spacer()
                    TextField("User ID", text:$profile.userId)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                }
                
                HStack {
                    Text("Bio")
                    Spacer()
                    TextField("Bio", text:$profile.bio, axis: .vertical)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                }
                
                DatePicker(selection: $profile.birthDate, in: dateRange, displayedComponents: .date) {
                    Text("Birth Date")
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var profile = UserProfile(name: "John Appleseed", userId: "johnappleseed", bio: "This is my profile. ", profileImageURL: nil, birthDate: Date(timeIntervalSince1970: 0))
    
    ProfileEditView(profile: $profile)
}
