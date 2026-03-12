//
//  TaskListView.swift
//  ToDoHolic
//
//  Created by Ibrahim Yondem and Baris Isci on 2026-02-06.
//

import SwiftUI
import CoreData

struct TaskListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskItem.dueDate, ascending: true)],
        animation: .default
    )
    private var allTasks: FetchedResults<TaskItem>

    var filterCategory: String? = nil

    private var filteredTasks: [TaskItem] {
        guard let category = filterCategory else { return Array(allTasks) }
        return allTasks.filter { $0.category == category }
    }

    private var overdueTasks: [TaskItem] {
        let now = Date()
        return filteredTasks.filter {
            !$0.isCompleted && ($0.dueDate ?? now) < now
        }
    }

    private var todayTasks: [TaskItem] {
        let now = Date()
        let endOfDay = Calendar.current.startOfDay(for: now).addingTimeInterval(86400)
        return filteredTasks.filter {
            !$0.isCompleted &&
            ($0.dueDate ?? now) >= now &&
            ($0.dueDate ?? now) < endOfDay
        }
    }

    private var upcomingTasks: [TaskItem] {
        let endOfDay = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        return filteredTasks.filter {
            !$0.isCompleted && ($0.dueDate ?? Date()) >= endOfDay
        }
    }

    private var completedTasks: [TaskItem] {
        filteredTasks.filter { $0.isCompleted }
    }

    var body: some View {
        Group {
            if filteredTasks.isEmpty {
                emptyStateView
            } else {
                taskListContent
            }
        }
        .navigationTitle(filterCategory ?? "All Tasks")
        .navigationBarTitleDisplayMode(.large)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No tasks yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Tap the '+' button on the dashboard\nto add your first task.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var taskListContent: some View {
        List {
            if !overdueTasks.isEmpty {
                Section {
                    ForEach(overdueTasks, id: \.objectID) { task in
                        TaskRowView(task: task, onToggle: toggleCompletion)
                    }
                    .onDelete { offsets in
                        deleteTasks(from: overdueTasks, at: offsets)
                    }
                } header: {
                    Label("Overdue", systemImage: "exclamationmark.circle.fill")
                        .foregroundColor(.red)
                        .font(.subheadline.bold())
                }
            }

            if !todayTasks.isEmpty {
                Section {
                    ForEach(todayTasks, id: \.objectID) { task in
                        TaskRowView(task: task, onToggle: toggleCompletion)
                    }
                    .onDelete { offsets in
                        deleteTasks(from: todayTasks, at: offsets)
                    }
                } header: {
                    Label("Today", systemImage: "calendar")
                        .foregroundColor(.blue)
                        .font(.subheadline.bold())
                }
            }

            if !upcomingTasks.isEmpty {
                Section {
                    ForEach(upcomingTasks, id: \.objectID) { task in
                        TaskRowView(task: task, onToggle: toggleCompletion)
                    }
                    .onDelete { offsets in
                        deleteTasks(from: upcomingTasks, at: offsets)
                    }
                } header: {
                    Label("Upcoming", systemImage: "clock")
                        .foregroundColor(.orange)
                        .font(.subheadline.bold())
                }
            }

            if !completedTasks.isEmpty {
                Section {
                    ForEach(completedTasks, id: \.objectID) { task in
                        TaskRowView(task: task, onToggle: toggleCompletion)
                    }
                    .onDelete { offsets in
                        deleteTasks(from: completedTasks, at: offsets)
                    }
                } header: {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.subheadline.bold())
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func toggleCompletion(task: TaskItem) {
        task.isCompleted.toggle()
        do {
            try viewContext.save()
        } catch {
            print("Toggle save error: \(error.localizedDescription)")
        }
    }

    private func deleteTasks(from section: [TaskItem], at offsets: IndexSet) {
        offsets.map { section[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            print("Delete error: \(error.localizedDescription)")
        }
    }
}

struct TaskRowView: View {
    let task: TaskItem
    let onToggle: (TaskItem) -> Void

    private var categoryEmoji: String {
        switch task.category {
        case "Work":   return "💼"
        case "Study":  return "📚"
        case "Home":   return "🏠"
        case "Travel": return "✈️"
        default:       return "📌"
        }
    }

    private var dueDateText: String {
        guard let date = task.dueDate else { return "No date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: { onToggle(task) }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .secondary)
                    .font(.title3)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title ?? "Untitled")
                    .font(.body)
                    .fontWeight(.medium)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)

                HStack(spacing: 6) {
                    Text(categoryEmoji)
                        .font(.caption)
                    Text(dueDateText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationView {
        TaskListView()
            .environment(
                \.managedObjectContext,
                PersistenceController(inMemory: true).container.viewContext
            )
    }
}
