// DashboardView.swift
import SwiftUI
import CoreData

struct DashboardView: View {
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("taskCustomCategoriesVersion") private var categoryListVersion = 0
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddTask = false
    @State private var showingAddCategory = false

    @FetchRequest(sortDescriptors: [])
    private var allTasks: FetchedResults<TaskItem>

    private var dashboardCategories: [String] {
        _ = categoryListVersion
        return TaskCategories.allCategories()
    }

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    private func count(for category: String) -> Int {
        allTasks.filter { $0.category == category && !$0.isCompleted }.count
    }

    private func overdueCount(for category: String) -> Int {
        let now = Date()
        return allTasks.filter {
            $0.category == category && !$0.isCompleted && ($0.dueDate ?? now) < now
        }.count
    }

    private func subtitle(for category: String) -> String {
        let overdue = overdueCount(for: category)
        let total = count(for: category)
        if total == 0 { return "No tasks" }
        if overdue > 0 { return "\(overdue) overdue" }
        return "\(total) pending"
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            if !userName.isEmpty {
                                Text("Hi, \(userName)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Text("Your Tasks")
                                .font(.system(size: 34, weight: .bold))
                                .tracking(-1)
                        }
                        Spacer()
                        NavigationLink(destination: ProfileView()) {
                            Image(systemName: "person.circle")
                                .font(.title)
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Profile")
                    }
                    .padding(.top, 20)

                    HStack(alignment: .firstTextBaseline) {
                        Text("CATEGORIES")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button {
                            showingAddCategory = true
                        } label: {
                            Label("Add category", systemImage: "plus.circle.fill")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }

                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(dashboardCategories, id: \.self) { category in
                            NavigationLink(destination: TaskListView(filterCategory: category)) {
                                CategoryCard(
                                    emoji: TaskCategories.emoji(for: category),
                                    title: category,
                                    count: count(for: category),
                                    subtitle: subtitle(for: category)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("TODAY")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)

                        let todayTasks = allTasks.filter {
                            guard !$0.isCompleted, let due = $0.dueDate else { return false }
                            let now = Date()
                            let endOfDay = Calendar.current.startOfDay(for: now).addingTimeInterval(86400)
                            return due >= now && due < endOfDay
                        }

                        if todayTasks.isEmpty {
                            Text("No tasks for today")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.gray.opacity(0.2),
                                                style: StrokeStyle(lineWidth: 1, dash: [5]))
                                )
                        } else {
                            ForEach(todayTasks, id: \.objectID) { task in
                                HStack {
                                    Text(task.title ?? "")
                                        .font(.subheadline)
                                    Spacer()
                                    Text(task.category ?? "")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.white)
                                .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.top, 10)
                }
                .padding()
            }

            Button(action: { showingAddTask = true }) {
                Image(systemName: "plus")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            }
            .padding(.trailing, 25)
            .padding(.bottom, 25)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
        }
        .sheet(isPresented: $showingAddCategory) {
            AddCategorySheet()
        }
    }
}

private struct AddCategorySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var newCategoryName = ""
    @State private var validationMessage: String?

    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Category name", text: $newCategoryName)
                        .autocapitalization(.words)
                } footer: {
                    if let validationMessage {
                        Text(validationMessage)
                            .foregroundColor(.red)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Add category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let error = TaskCategories.addCustom(newCategoryName) {
                            validationMessage = error
                        } else {
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
            .onChange(of: newCategoryName) { _ in
                validationMessage = nil
            }
        }
    }
}

struct ProfileView: View {
    @AppStorage("userName") private var userName: String = ""

    @FetchRequest(sortDescriptors: [])
    private var allTasks: FetchedResults<TaskItem>

    @State private var editedName: String = ""

    private var activeCount: Int {
        allTasks.filter { !$0.isCompleted }.count
    }

    private var completedCount: Int {
        allTasks.filter { $0.isCompleted }.count
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Spacer()
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 72))
                        .foregroundColor(.blue)
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            Section(
                header: Text("Display name"),
                footer: Text("Used for the Hi line on the home screen.")
            ) {
                TextField("Your name", text: $editedName)
                    .autocapitalization(.words)
            }

            Section(header: Text("Task overview")) {
                LabeledContent("Active", value: "\(activeCount)")
                LabeledContent("Completed", value: "\(completedCount)")
                LabeledContent("Total", value: "\(allTasks.count)")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let trimmed = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    userName = trimmed
                }
                .disabled(editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .onAppear {
            editedName = userName
        }
    }
}

struct CategoryCard: View {
    let emoji: String
    let title: String
    let count: Int
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(emoji).font(.title)
                Spacer()
                Text("\(count)")
                    .font(.title2).fontWeight(.bold)
                    .foregroundColor(count > 0 ? .primary : .secondary.opacity(0.5))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle)
                    .font(.caption).fontWeight(.medium)
                    .foregroundColor(subtitle.contains("overdue") ? .red : .secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 140, alignment: .leading)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { DashboardView() }
    }
}