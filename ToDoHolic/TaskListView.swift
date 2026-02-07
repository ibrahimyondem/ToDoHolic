//
//  TaskListView.swift
//  ToDoHolic
//
//  Created by Ibrahim Yondem and Baris Isci on 2026-02-06.
//

import SwiftUI

struct TaskListView: View {
    let categoryName: String // This will be passed from the Dashboard
    
    var body: some View {
        List {
            // Section 1: Overdue Tasks
            Section(header: Text("OVERDUE").foregroundColor(.red).font(.caption).bold()) {
                TaskRow(title: "Submit Q3 Report", time: "Yesterday, 5:00 PM", isOverdue: true)
            }
            
            // Section 2: Tasks for Today
            Section(header: Text("TODAY").font(.caption).bold()) {
                TaskRow(title: "Client Meeting Prep", time: "In 30 mins", isCloseToDue: true)
                TaskRow(title: "Review Designs", time: "2:00 PM")
            }
            
            // Section 3: Completed Tasks
            Section(header: Text("COMPLETED").foregroundColor(.green).font(.caption).bold()) {
                TaskRow(title: "Send Invoice #1024", time: "Done at 9:15 AM", isCompleted: true)
            }
        }
        .navigationTitle(categoryName)
        .listStyle(InsetGroupedListStyle())
    }
}

// Row component for individual tasks
struct TaskRow: View {
    let title: String
    let time: String
    var isOverdue: Bool = false
    var isCloseToDue: Bool = false
    var isCompleted: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isCompleted ? .green : (isOverdue ? .red : .gray))
            
            VStack(alignment: .leading) {
                Text(title)
                    .strikethrough(isCompleted)
                    .fontWeight(.semibold)
                Text(time)
                    .font(.caption)
                    .foregroundColor(isOverdue ? .red : (isCloseToDue ? .orange : .gray))
            }
        }
        .padding(.vertical, 4)
    }
}
