//
//  CygnvsTaskApp.swift
//  CygnvsTask
//
//  Created by Raghuraman.A on 22/02/23.
//

import SwiftUI

@main
struct CygnvsTaskApp: App {
    var body: some Scene {
        WindowGroup {
            AlbumListView(viewModel: AlbumViewModel())
                .environment(\.managedObjectContext, CoreDataStack.shared.persistentContainer.viewContext)
        }
    }
}
