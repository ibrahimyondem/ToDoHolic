//
//  AddTaskView.swift
//  ToDoHolic
//
//  Created by Ibrahim Yondem and Baris Isci on 2026-02-06.
//

import SwiftUI

struct AddTaskView: View {
    // We use @Environment to allow the "X" button to close this screen
    @Environment(\.presentationMode) var presentationMode
    
    @State private var taskTitle: String = ""
    @State private var selectedDate = Date()
    @State private var selectedCategory = "Work"
    
    let categories = ["Work", "Study", "Home", "Travel"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with Close Button
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("New Task")
                    .font(.headline)
                Spacer()
                // Empty view to balance the header
                Color.clear.frame(width: 20, height: 20)
            }
            .padding(.bottom, 10)
            
            // Task Title Input
            Text("What are you planning?")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.gray)
            
            TextField("Enter task title", text: $taskTitle)
                .font(.title)
                .fontWeight(.bold)
            
            Divider()
            
            // Date Picker
            DatePicker("Date & Time", selection: $selectedDate)
                .datePickerStyle(CompactDatePickerStyle())
                .font(.headline)
            
            // Category Selection
            Text("CATEGORY")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            
            HStack {
                ForEach(categories, id: \.self) { category in
                    Button(action: { selectedCategory = category }) {
                        Text(category)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedCategory == category ? Color.blue : Color.gray.opacity(0.1))
                            .foregroundColor(selectedCategory == category ? .white : .primary)
                            .cornerRadius(10)
                    }
                }
            }
            
            Spacer()
            
            // Create Task Button
            Button(action: {
                // TODO: Save task to Core Data here
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Create Task →")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(taskTitle.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(15)
            }
            .disabled(taskTitle.isEmpty)
        }
        .padding(30)
    }
}
