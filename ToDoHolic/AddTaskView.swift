//
//  AddTaskView.swift
//  ToDoHolic
//
//  Created by Ibrahim Yondem and Baris Isci on 2026-02-06.
//

import SwiftUI
import CoreData

struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var taskTitle: String = ""
    @State private var dueDate: Date = Date()
    @State private var selectedCategory: String = "Work"
    @State private var showingValidationAlert: Bool = false

    let categories = ["Work", "Study", "Home", "Travel"]

    private func emoji(for category: String) -> String {
        switch category {
        case "Work":   return "💼"
        case "Study":  return "📚"
        case "Home":   return "🏠"
        case "Travel": return "✈️"
        default:       return "📌"
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task title", text: $taskTitle)
                        .autocapitalization(.sentences)
                }

                Section(header: Text("Due Date")) {
                    DatePicker(
                        "Select date",
                        selection: $dueDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                }

                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(.segmented)

                    HStack {
                        Spacer()
                        Text(emoji(for: selectedCategory))
                            .font(.largeTitle)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    Button(action: saveTask) {
                        HStack {
                            Spacer()
                            Text("Create Task")
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .background(taskTitle.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                    }
                    .disabled(taskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal)
                }
            }
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Missing Title", isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enter a title for your task before saving.")
            }
        }
    }

    private func saveTask() {
        let trimmedTitle = taskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else {
            showingValidationAlert = true
            return
        }

        let newTask = TaskItem(context: viewContext)
        newTask.id = UUID()
        newTask.title = trimmedTitle
        newTask.dueDate = dueDate
        newTask.category = selectedCategory
        newTask.isCompleted = false

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Core Data save error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AddTaskView()
        .environment(
            \.managedObjectContext,
            PersistenceController(inMemory: true).container.viewContext
        )
}
