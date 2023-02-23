//
//  CoreDataStack.swift
//  CygnvsTask
//
//  Created by Raghuraman.A on 22/02/23.
//

import Foundation
import CoreData

///`CoreDataStack` handle all the stack components related to coredata
///It is responsiable for crating `NSPersistentContainer`, `NSManagedObjectContext` and maintaining them
class CoreDataStack {
    static var shared = CoreDataStack()
    
    private let inMemory: Bool
    private var notificationToken: NSObjectProtocol?

    private init(inMemory: Bool = false) {
        self.inMemory = inMemory

        notificationToken = NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: nil) { note in
            Task {
                await self.fetchPersistentHistory()
            }
        }
    }

    deinit {
        if let observer = notificationToken {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    /// A peristent history token used for fetching transactions from the store.
    private var lastToken: NSPersistentHistoryToken?

    /// A persistent container to set up the Core Data stack.
    lazy var persistentContainer: NSPersistentContainer = {
        /// - Tag: persistentContainer
        let container = NSPersistentContainer(name: "Cygnvs")

        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }

        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }

        // Enable persistent store remote change notifications
        /// - Tag: persistentStoreRemoteChange
        description.setOption(true as NSNumber,
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)

        // Enable persistent history tracking
        /// - Tag: persistentHistoryTracking
        description.setOption(true as NSNumber,
                              forKey: NSPersistentHistoryTrackingKey)

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        // This sample refreshes UI by consuming store changes via persistent history tracking.
        /// - Tag: viewContextMergeParentChanges
        container.viewContext.automaticallyMergesChangesFromParent = false
        container.viewContext.name = "viewContext"
        /// - Tag: viewContextMergePolicy
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        return container
    }()

    /// Creates and configures a private queue context.
    func backgroundContext() -> NSManagedObjectContext {
        let taskContext = persistentContainer.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        taskContext.undoManager = nil
        return taskContext
    }
    
    func fetchPersistentHistory() async {
        do {
            try await fetchPersistentHistoryTransactionsAndChanges()
        } catch {
            print("\(error.localizedDescription)")
        }
    }

    private func fetchPersistentHistoryTransactionsAndChanges() async throws {
        let taskContext = backgroundContext()
        taskContext.name = "persistentHistoryContext"

        try await taskContext.perform {
            // Execute the persistent history change since the last transaction.
            /// - Tag: fetchHistory
            let changeRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: self.lastToken)
            let historyResult = try taskContext.execute(changeRequest) as? NSPersistentHistoryResult
            if let history = historyResult?.result as? [NSPersistentHistoryTransaction],
               !history.isEmpty {
                self.mergePersistentHistoryChanges(from: history)
                return
            }

            throw CustomError.INSERTION_FAILED
        }

    }

    private func mergePersistentHistoryChanges(from history: [NSPersistentHistoryTransaction]) {
        // Update view context with objectIDs from history change request.
        /// - Tag: mergeChanges
        let viewContext = persistentContainer.viewContext
        viewContext.perform {
            for transaction in history {
                viewContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
                self.lastToken = transaction.token
            }
        }
    }
    
    ///Save the main context
    func saveContext() throws {
        guard persistentContainer.viewContext.hasChanges else { return }
        try persistentContainer.viewContext.save()
    }
    
    ///Remove all the data stored in coredata
    func resetAllCoreData() throws {
        let entityNames = self.persistentContainer.managedObjectModel.entities.map({ $0.name!})
        try entityNames.forEach { entityName in
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            try persistentContainer.viewContext.execute(deleteRequest)
            try persistentContainer.viewContext.save()
        }
    }
}
