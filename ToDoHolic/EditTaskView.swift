import SwiftUI
import CoreData

struct EditTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @AppStorage("taskCustomCategoriesVersion") private var categoryListVersion = 0

    let task: TaskItem

    @State private var taskTitle: String
    @State private var dueDate: Date
    @State private var selectedCategory: String
    @State private var showingAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    private var categories: [String] {
        _ = categoryListVersion
        return TaskCategories.allCategories()
    }

    init(task: TaskItem) {
        self.task = task
        _taskTitle = State(initialValue: task.title ?? "")
        let existingDue = task.dueDate ?? Date()
        _dueDate = State(initialValue: max(existingDue, Date()))
        _selectedCategory = State(initialValue: task.category ?? "Work")
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
                        ForEach(categories, id: \.self) { category in
                            Text("\(TaskCategories.emoji(for: category))  \(category)").tag(category)
                        }
                    }
                }

                Section {
                    Button(action: saveChanges) {
                        HStack {
                            Spacer()
                            Text("Save Changes")
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .background(taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(10)
                    }
                    .disabled(taskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Edit Task")
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
                dueDate = max(dueDate, Date())
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

    private func saveChanges() {
        let trimmedTitle = taskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            alertTitle = "Missing Title"
            alertMessage = "Please enter a title before saving."
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

        task.title = trimmedTitle
        task.dueDate = dueDate
        task.category = selectedCategory

        do {
            try viewContext.save()
            dismiss()
        } catch {
            alertTitle = "Save Failed"
            alertMessage = "Your task changes could not be saved. Please try again."
            showingAlert = true
        }
    }
}

#Preview {
    let context = PersistenceController(inMemory: true).container.viewContext
    let sampleTask = TaskItem(context: context)
    sampleTask.id = UUID()
    sampleTask.title = "Sample task"
    sampleTask.dueDate = Date()
    sampleTask.category = "Work"
    sampleTask.isCompleted = false

    return EditTaskView(task: sampleTask)
        .environment(\.managedObjectContext, context)
}
