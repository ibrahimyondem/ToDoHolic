// DashboardView.swift
import SwiftUI
import CoreData

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingAddTask = false

    @FetchRequest(sortDescriptors: [])
    private var allTasks: FetchedResults<TaskItem>

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    // Helpers to compute real counts per category
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
                        Text("Your Tasks")
                            .font(.system(size: 34, weight: .bold))
                            .tracking(-1)
                        Spacer()
                        Image(systemName: "person.circle")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)

                    LazyVGrid(columns: columns, spacing: 16) {
                        NavigationLink(destination: TaskListView(filterCategory: "Work")) {
                            CategoryCard(emoji: "💼", title: "Work",
                                count: count(for: "Work"), subtitle: subtitle(for: "Work"))
                        }
                        .buttonStyle(PlainButtonStyle())

                        NavigationLink(destination: TaskListView(filterCategory: "Study")) {
                            CategoryCard(emoji: "📚", title: "Study",
                                count: count(for: "Study"), subtitle: subtitle(for: "Study"))
                        }
                        .buttonStyle(PlainButtonStyle())

                        NavigationLink(destination: TaskListView(filterCategory: "Home")) {
                            CategoryCard(emoji: "🏠", title: "Home",
                                count: count(for: "Home"), subtitle: subtitle(for: "Home"))
                        }
                        .buttonStyle(PlainButtonStyle())

                        NavigationLink(destination: TaskListView(filterCategory: "Travel")) {
                            CategoryCard(emoji: "✈️", title: "Travel",
                                count: count(for: "Travel"), subtitle: subtitle(for: "Travel"))
                        }
                        .buttonStyle(PlainButtonStyle())

                        NavigationLink(destination: TaskListView(filterCategory: "Music")) {
                            CategoryCard(emoji: "🎵", title: "Music",
                                count: count(for: "Music"), subtitle: subtitle(for: "Music"))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    // TODAY section — now shows real tasks
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
    }
}

// CategoryCard — unchanged from your original
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