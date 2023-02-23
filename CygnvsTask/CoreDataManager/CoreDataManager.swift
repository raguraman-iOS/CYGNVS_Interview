//
//  CoreDataManager.swift
//  CygnvsTask
//
//  Created by Raghuraman.A on 22/02/23.
//

import Foundation
import CoreData

///`CoreDataManager` interact with `CoreDataStack`
///Responsiable for all the coredata related actions in the app
class CoreDataManager {
    
    static var shared = CoreDataManager()
    
    /// Uses `NSBatchInsertRequest` (BIR) to import a JSON dictionary into the Core Data store on a private queue.
    /// saves the list of `[AlbumModel]` to the coredata
    /// - Parameters albums: The list of `AlbumModel`
    func saveAlbums(from albums: [AlbumModel]) throws {
        guard !albums.isEmpty else { return }
        
        let taskContext = CoreDataStack.shared.backgroundContext()
        taskContext.name = "importContext"
        taskContext.transactionAuthor = "importAlbums"
        
        /// - Tag: performAndWait
        try taskContext.performAndWait {
            // Execute the batch insert.
            /// - Tag: batchInsertRequest
            let batchInsertRequest = self.newBatchInsertRequest(with: albums)
            if let fetchResult = try? taskContext.execute(batchInsertRequest),
               let batchInsertResult = fetchResult as? NSBatchInsertResult,
               let success = batchInsertResult.result as? Bool, success {
                return
            }
            throw CustomError.INSERTION_FAILED
        }
    }
    
    /// Clean all the coredata content
    func clearData() throws {
        try CoreDataStack.shared.resetAllCoreData()
    }
    
    /// Update the album with given title
    /// - Parameters title: title is a `String` that is needed to be updated
    /// - Parameters album: `album` is the `Album` model that is needed to be updated
    func update(title: String, for album: Album) throws {
        let taskContext = CoreDataStack.shared.backgroundContext()
        taskContext.name = "updateContext"
        taskContext.transactionAuthor = "updateAlbumTitle"
        
        let albumID = album.objectID
        
        /// - Tag: performAndWait
        try taskContext.performAndWait {
            guard let albumObj = taskContext.object(with: albumID) as? Album else {
                throw CustomError.UPDATE_FAILED
            }
            albumObj.title = title
            try taskContext.save()
        }
    }
    
    private func newBatchInsertRequest(with albumList: [AlbumModel]) -> NSBatchInsertRequest {
        var index = 0
        let total = albumList.count
        
        // Provide one dictionary at a time when the closure is called.
        let batchInsertRequest = NSBatchInsertRequest(entity: Album.entity(), dictionaryHandler: { dictionary in
            guard index < total else { return true }
            dictionary.addEntries(from: albumList[index].dictionaryValue)
            index += 1
            return false
        })
        return batchInsertRequest
    }
}
