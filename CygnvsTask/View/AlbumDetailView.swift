//
//  AlbumDetailView.swift
//  CygnvsTask
//
//  Created by Raghuraman.A on 22/02/23.
//

import SwiftUI

struct AlbumDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: AlbumViewModel
    @State private var editMode: EditMode = .inactive
    @State private var editText: String = ""
    @FocusState private var field: Bool?
    var albumModel: Album
    
    var body: some View {
        VStack {
            RemoteImage(url: albumModel.url)
                .frame(width: 200, height: 200)
                .clipped()
            
            if self.editMode == .active {
                HStack {
                    Spacer()
                    TextField("Title", text: self.$editText)
                        .multilineTextAlignment(.center)
                        .focused(self.$field, equals: true)
                        .onAppear {
                            self.field = true
                        }
                    Spacer()
                }
                
            } else {
                Text(albumModel.title ?? "")
            }
            
            
            Spacer()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if editMode == .active {
                    SaveButton(editMode: self.$editMode) {
                        editMode = .inactive
                        self.field = nil
                        self.viewModel.update(title: self.editText, for: self.albumModel)
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton(editMode: $editMode) {
                    editMode = .inactive
                    self.resetEditText()
                }
            }
        }
        .navigationTitle("")
        .onAppear {
            self.resetEditText()
        }
    }
    
    private func resetEditText() {
        self.editText = albumModel.title ?? ""
    }
}

struct AlbumDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumDetailView(viewModel: AlbumViewModel(), albumModel: Album(entity: Album.entity(), insertInto: CoreDataStack.shared.persistentContainer.viewContext))
    }
}
