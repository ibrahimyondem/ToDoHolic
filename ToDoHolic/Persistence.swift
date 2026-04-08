//
//  Persistence.swift
//  ToDoHolic
//
//  Created by Ibrahim Yondem and Baris Isci on 2026-02-06.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ToDoHolic")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Persistent store load failed for \(storeDescription.url?.absoluteString ?? "unknown"): \(error.localizedDescription)")

                guard !inMemory else {
                    print("In-memory store could not be initialized.")
                    return
                }

                container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
                container.loadPersistentStores { fallbackDescription, fallbackError in
                    if let fallbackError = fallbackError as NSError? {
                        print("Fallback in-memory store failed for \(fallbackDescription.url?.absoluteString ?? "unknown"): \(fallbackError.localizedDescription)")
                    } else {
                        print("Core Data fallback to in-memory store succeeded.")
                    }
                }
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
