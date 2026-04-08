import SwiftUI
import CoreData

struct EditTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let task: TaskItem

    @State private var taskTitle: String
    @State private var dueDate: Date
    @State private var selectedCategory: String
    @State private var showingValidationAlert: Bool = false

    private let categories = ["Work", "Study", "Home", "Travel"]

    init(task: TaskItem) {
        self.task = task
        _taskTitle = State(initialValue: task.title ?? "")
        _dueDate = State(initialValue: task.dueDate ?? Date())
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
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                }

                Section(header: Text("Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
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
            .alert("Missing Title", isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enter a title before saving.")
            }
        }
    }

    private func saveChanges() {
        let trimmedTitle = taskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            showingValidationAlert = true
            return
        }

        task.title = trimmedTitle
        task.dueDate = dueDate
        task.category = selectedCategory

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Edit save error: \(error.localizedDescription)")
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
