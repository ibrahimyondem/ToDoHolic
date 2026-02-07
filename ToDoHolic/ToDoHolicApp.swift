//
//  ToDoHolicApp.swift
//  ToDoHolic
//
//  Created by Ibrahim Yondem and Baris Isci on 2026-02-06.
//

import SwiftUI

@main
struct ToDoHolicApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            WelcomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
