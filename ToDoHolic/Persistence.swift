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
        let persistentContainer = NSPersistentContainer(name: "ToDoHolic")
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                print("Persistent store load failed for \(storeDescription.url?.absoluteString ?? "unknown"): \(error.localizedDescription)")

                guard !inMemory else {
                    print("In-memory store could not be initialized.")
                    return
                }

                persistentContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
                persistentContainer.loadPersistentStores { fallbackDescription, fallbackError in
                    if let fallbackError = fallbackError as NSError? {
                        print("Fallback in-memory store failed for \(fallbackDescription.url?.absoluteString ?? "unknown"): \(fallbackError.localizedDescription)")
                    } else {
                        print("Core Data fallback to in-memory store succeeded.")
                    }
                }
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        container = persistentContainer
    }
}

enum TaskCategories {
    private static let customKey = "taskCustomCategoryNames"
    private static let versionKey = "taskCustomCategoriesVersion"

    static let builtIn: [String] = ["Work", "Study", "Home", "Travel", "Other"]

    static func customList() -> [String] {
        UserDefaults.standard.stringArray(forKey: customKey) ?? []
    }

    static func allCategories() -> [String] {
        builtIn + customList()
    }

    @discardableResult
    static func addCustom(_ rawName: String) -> String? {
        let name = rawName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return "Please enter a category name." }
        if builtIn.contains(where: { $0.caseInsensitiveCompare(name) == .orderedSame }) {
            return "That name is already a default category."
        }
        var custom = customList()
        if custom.contains(where: { $0.caseInsensitiveCompare(name) == .orderedSame }) {
            return "This category already exists."
        }
        custom.append(name)
        UserDefaults.standard.set(custom, forKey: customKey)
        bumpVersion()
        return nil
    }

    private static func bumpVersion() {
        let v = UserDefaults.standard.integer(forKey: versionKey)
        UserDefaults.standard.set(v + 1, forKey: versionKey)
    }

    static func emoji(for category: String) -> String {
        switch category {
        case "Work":   return "💼"
        case "Study":  return "📚"
        case "Home":   return "🏠"
        case "Travel": return "✈️"
        case "Other":  return "📋"
        default:       return "🏷️"
        }
    }
}
