import SwiftUI

struct DashboardView: View {
    // State to control the visibility of the "Add Task" pop-up
    @State private var showingAddTask = false
    
    // 2-column grid layout for the category cards [cite: 96]
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        // ZStack allows the "+" button to float on top of the ScrollView [cite: 97, 141]
        ZStack(alignment: .bottomTrailing) {
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Header Section matches "Your Tasks" mockup [cite: 143]
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
                    
                    // The Grid of Categories showing task counts [cite: 98, 141]
                    LazyVGrid(columns: columns, spacing: 16) {
                        // NavigationLink connects the 'Work' card to the Task List [cite: 99]
                        NavigationLink(destination: TaskListView(categoryName: "Work")) {
                            CategoryCard(emoji: "💼", title: "Work", count: 5, subtitle: "2 overdue")
                        }
                        .buttonStyle(PlainButtonStyle())
                        //Dummy cards for other categories - these can be replaced with dynamic data later [cite: 98, 141]
                        CategoryCard(emoji: "📚", title: "Study", count: 3, subtitle: "Next: Physics")
                        CategoryCard(emoji: "🏠", title: "Home", count: 4, subtitle: "Groceries")
                        CategoryCard(emoji: "✈️", title: "Travel", count: 0, subtitle: "No tasks")
                        CategoryCard(emoji: "🎵", title: "Music", count: 0, subtitle: "No tasks")
                    }
                    
                    // "Today" Section placeholder [cite: 162, 163]
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
            
            // Floating Action Button (+) as specified in your requirements [cite: 97, 164]
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
        .navigationBarBackButtonHidden(true) // Prevents going back to Welcome screen [cite: 89]
        // Triggers the "Add New Task" screen as a modal sheet [cite: 102, 106]
        .sheet(isPresented: $showingAddTask) {
            AddTaskView()
        }
    }
}

// Reusable component for the Category Grid Cards [cite: 96, 141]
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
                    // Visual indicator for overdue tasks [cite: 85, 86, 111]
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

// Preview provider for older Xcode versions
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DashboardView()
        }
    }
}
