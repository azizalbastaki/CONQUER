//
//  todaystodoview.swift
//  CONQUER
//
//  Created by Abdulaziz Albastaki on 30/12/2023.
//

import SwiftUI
import SwiftData

struct todaystodoview: View {
    var ourModelContext: ModelContext
    var entries: [Item]
    var addFunction: (String, Date, Int, String, String, [SubTask]) -> Void
    var initializeConquer: () -> Void
    var addEntry: (String) -> Item
    @State var subtasks: [SubTask] = [SubTask(taskText: "")]
    @State var dateShown = getTodaysDate()
    @State var taskTitle = ""
    @State var taskDescription = ""
    @State var taskDuration = 30
    @State var date = Date.now
    @State var taskTag = ""
    
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    HStack {
                        Text("Daily Tasks")
                            .font(.title)
                            .padding(.horizontal)
                            .bold()
                        
                        Spacer()
                        DatePicker(selection: $date, displayedComponents: .date, label: {(Text("Showing Tasks for: "))})
                            .labelsHidden()
                        
                        NavigationLink {
                            Form {
                                Section("Task Name") {
                                    TextField("Task Name", text: self.$taskTitle)
                                }
                                
                                Section("Task Description") {
                                    TextField("What are the long term goals that you are hoping to achieve with this task?", text: self.$taskDescription, axis: .vertical)
                                        .lineLimit(2...)
                                    
                                }
                                
                                Section("Duration of Task (in minutes)") {
                                    TextField("In minutes, how long will this task take?", value: self.$taskDuration, formatter: NumberFormatter())
                                        .keyboardType(.numberPad)
                                }
                                
                                Section("Date of Task") {
                                    DatePicker(selection: $date, in: Date.now..., displayedComponents: .date) {
                                        Text("Task set for \(DateFormatter().string(from: date))")
                                    }
                                    
                                }
                                Section("Tagging") {
                                    TextField("Tag this Task", text: $taskTag)
                                        .frame(alignment: .center)
                                }
                                
                                Section("Sub Tasks, break the task down into small, concise instructions") {
                                    List {
                                        ForEach(self.$subtasks, id:\.self) { subtask in
                                            TextField("Instruction", text: subtask.taskText)
                                        }
                                        .onDelete(perform: deleteSubtask)
                                    }
                                    
                                    Button(action: {self.subtasks.append(SubTask(taskText: ""))}, label: {
                                        Text("Add New Instruction")
                                            .padding(.trailing)
                                            
                                    })
                                }
                                
                                Button(action: {
                                    self.addFunction(taskTitle, date, taskDuration,taskDescription, taskTag, subtasks)
                                    self.taskTitle = ""
                                    self.taskDescription = ""
                                    self.taskDuration = 30
                                    self.subtasks = [SubTask(taskText: "")]
                                    self.taskTag = ""
                                },
                                       label: {
                                    HStack {
                                        Spacer()
                                        Text("Add Task")
                                            .padding(.trailing)
                                            .font(.system(size: 25))
                                        Spacer()
                                    }
                                    
                                    
                                })
                            }
                        } label: {
                            Text("+")
                                .padding(.trailing)
                                .font(.system(size: 25))
                        }
                    }
                }
                .padding(.horizontal)
                List {
                    ForEach(getTodaysEntry(items: entries, initializeFunc: self.initializeConquer, newEntryFunc: self.addEntry).tasks!) { entry in
                        todoRow(taskTitle: entry.taskTitle, tagTitle: entry.tag, duration: entry.duration, taskDescription: entry.taskDescription, taskInstructions: entry.subTasks)
                    }
                }
            }
        }
    }
    
    
    func getTodaysEntry(items: [Item], initializeFunc: () -> Void, newEntryFunc: (String) -> Item) -> Item {
        let dateWanted = getDateAsString(dateObject: date)
        if (searchForEntry(items: items, entryTimestamp: dateWanted) != nil) {
            return searchForEntry(items: items, entryTimestamp: dateWanted)!
        }
        
        else {
            if (items.count == 0) {
                initializeFunc()
            }
            return newEntryFunc(dateWanted)
            //return searchForEntry(items: self.entries, entryTimestamp: dateWanted)!
        }
    }
    
    func searchForEntry(items: [Item], entryTimestamp: String) -> Item? {
        for item in items {
            if (item.timestamp == entryTimestamp) {
                return item
            }
        }
        return nil
    }
    
    func deletething() {
        do {
            try ourModelContext.delete(model: Item.self)
            initializeConquer()
        } catch {
            print("Could not delete.")
        }
    }
    
    func deleteSubtask(at offsets: IndexSet) {
        subtasks.remove(atOffsets: offsets)
    }
    
}
func dothing() {
    print("Hello")
}

struct todoRow: View {
    @State var isOn = false
    var taskTitle: String
    var tagTitle: String
    var duration: Int
    var taskDescription: String
    var taskInstructions: [SubTask]
    var body: some View {
        HStack{
            Button(action: dothing, label: {
                Image(systemName: "circle")
            })
            
            NavigationLink {
                todoDetailedView(taskTitle: taskTitle, taskDescription: taskDescription, instructions: taskInstructions)
            } label: {
                HStack{
                    Text(taskTitle)
                    Spacer()
                    Text(tagTitle)
                        .background(.red)
                        .foregroundStyle(.white)
                        .safeAreaPadding(.horizontal, 5)
                    Text("\(String(duration)) minutes")
                    
                        .foregroundStyle(.white)
                        .background(.purple)
                        .safeAreaPadding(.horizontal, 5)
                }
            }
            
        }
        .lineLimit(1)
        .minimumScaleFactor(0.01)
    }
}

struct todoDetailedView: View {
    var taskTitle: String
    var taskDescription: String
    var instructions: [SubTask]
    var body: some View {
        VStack {
            Text(taskTitle)
                .font(.title)
                .padding(.horizontal)
                .bold()
            Text(taskDescription)
                .font(.subheadline)
                .padding(.horizontal)
            
            if (instructions != [] && !(instructions.count == 1 && instructions[0].taskText == "")) {
                List {
                    ForEach(instructions) { instruction in
                        
                        Text(instruction.taskText)
                        
                    }
                }
            }
            else {
                Text("No Subtasks Provided")
            }
            
        }
    }
}

//#Preview {
//    todaystodoview()
//}
