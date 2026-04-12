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

    @AppStorage("taskCustomCategoriesVersion") private var categoryListVersion = 0

    @State private var taskTitle: String = ""
    @State private var dueDate: Date = Date()
    @State private var selectedCategory: String = "Work"
    @State private var showingAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    private var categories: [String] {
        _ = categoryListVersion
        return TaskCategories.allCategories()
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
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                }

                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { cat in
                            Text("\(TaskCategories.emoji(for: cat))  \(cat)").tag(cat)
                        }
                    }

                    HStack {
                        Spacer()
                        Text(TaskCategories.emoji(for: selectedCategory))
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
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
            .onAppear {
                if !categories.contains(selectedCategory) {
                    selectedCategory = categories.first ?? "Work"
                }
            }
            .onChange(of: categoryListVersion) { _ in
                if !categories.contains(selectedCategory) {
                    selectedCategory = categories.first ?? "Work"
                }
            }
        }
    }

    private func saveTask() {
        let trimmedTitle = taskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else {
            alertTitle = "Missing Title"
            alertMessage = "Please enter a title for your task before saving."
            showingAlert = true
            return
        }

        let now = Date()
        guard dueDate >= now else {
            alertTitle = "Invalid Due Date"
            alertMessage = "Choose a date and time in the present or future."
            showingAlert = true
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
            alertTitle = "Save Failed"
            alertMessage = "Your task could not be saved. Please try again."
            showingAlert = true
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
