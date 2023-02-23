//
//  ContentView.swift
//  CygnvsTask
//
//  Created by Raghuraman.A on 22/02/23.
//

import SwiftUI

struct AlbumListView: View {
    @FetchRequest(sortDescriptors: [SortDescriptor(\.id, order: .reverse)]) private var albumList: FetchedResults<Album>
    @ObservedObject var viewModel: AlbumViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    ForEach(albumList) { album in
                        NavigationLink(destination: AlbumDetailView(viewModel: self.viewModel, albumModel: album)) {
                            AlbumCard(title: album.title ?? "", imageURL: album.url)
                        }
                    }
                }
                .listStyle(SidebarListStyle())
                .refreshable {
                    self.loadData()
                }
                
                EmptyView()
                
                if self.viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                }
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        Text("number of albums \(self.albumList.count)")
                            .padding(.bottom, 40)
                        Spacer()
                    }
                    .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("Award List")
            .alert(isPresented: .constant(self.viewModel.showError) , error: self.viewModel.error) { }
            
            .onAppear {
                if self.albumList.count == 0 {
                    self.loadData()
                }
            }
        }
    }
    
    private func loadData() {
        self.viewModel.loadData()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumListView(viewModel: AlbumViewModel())
    }
}

extension View {
   @ViewBuilder
   func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
        if conditional {
            content(self)
        } else {
            self
        }
    }
}
