import SwiftUI

struct DashboardView: View {
    // State to control the visibility of the "Add Task" pop-up
    @State private var showingAddTask = false
    
    // 2-column grid layout for the category cards
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        // ZStack allows the "+" button to float on top
        ZStack(alignment: .bottomTrailing) {
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Header Section
                    HStack {
                        Text("Your Tasks")
                            .font(.system(size: 34, weight: .bold))
                            .tracking(-1)
                        Spacer()
                        // Profile icon placeholder
                        Image(systemName: "person.circle")
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Grid of Categories showing task counts
                    LazyVGrid(columns: columns, spacing: 16) {
                        // Work category links to task list
                        NavigationLink(destination: TaskListView(categoryName: "Work")) {
                            CategoryCard(emoji: "💼", title: "Work", count: 5, subtitle: "2 overdue")
                        }
                        .buttonStyle(PlainButtonStyle())
                        // TODO: Make these other categories clickable too
                        CategoryCard(emoji: "📚", title: "Study", count: 3, subtitle: "Next: Physics")
                        CategoryCard(emoji: "🏠", title: "Home", count: 4, subtitle: "Groceries")
                        CategoryCard(emoji: "✈️", title: "Travel", count: 0, subtitle: "No tasks")
                        CategoryCard(emoji: "🎵", title: "Music", count: 0, subtitle: "No tasks")
                    }
                    
                    // "Today" Section - will add real tasks later
                    VStack(alignment: .leading, spacing: 12) {
                        Text("TODAY")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        Text("No tasks for today")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 30)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [5]))
                            )
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            
            // Floating + button to add new tasks
            Button(action: {
                showingAddTask = true // Triggers the AddTaskView pop-up
            }) {
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

// Card component for each category
struct CategoryCard: View {
    let emoji: String
    let title: String
    let count: Int
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(emoji)
                    .font(.title)
                Spacer()
                Text("\(count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(count > 0 ? .primary : .secondary.opacity(0.5))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .fontWeight(.medium)
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
        NavigationView {
            DashboardView()
        }
    }
}
