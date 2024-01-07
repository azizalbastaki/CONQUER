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
    var addFunction: (String, Date, Int, String, String, [SubTask], Int) -> Void
    var initializeConquer: () -> Void
    var addEntry: (String) -> Item
    var toggleTask: (String, UUID) -> Bool
    var toggleSubTask: (String, UUID, UUID) -> Bool
    //var deleteTodo: (IndexSet) -> Void
    @State var subtasks: [SubTask] = [SubTask(taskText: "")]
    @State var taskTitle = ""
    @State var taskDescription = ""
    @State var taskDuration = 30
    @State var date = Date.now
    @State var taskTag = ""
    @State var timeSelected = Date.now
    
    
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
                                    TextField("Keep it brief!", text: self.$taskTitle)
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
                                
                                Section("Time of Task") {
                                    DatePicker("Please enter a time", selection: $timeSelected, displayedComponents: .hourAndMinute)
                                }
                                
                                Section("Tagging") {
                                    TextField("Give this task a label", text: $taskTag)
                                        .frame(alignment: .center)
                                }
                                
                                Section("Sub Instructions - break the task down") {
                                    List {
                                        ForEach(self.$subtasks) { $subtask in
                                            TextField("Keep it small and concise", text: $subtask.taskText)
                                        }
                                        .onDelete(perform: deleteSubtask)
                                    }
                                    
                                    Button(action: {self.subtasks.append(SubTask(taskText: ""))}, label: {
                                        Text("Add New Instruction")
                                            .padding(.trailing)
                                        
                                    })
                                }
                                
                                Button(action: {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "HHmm"
                                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                    let timeAsString = dateFormatter.string(from: self.timeSelected)
                                    self.addFunction(taskTitle, date, taskDuration,taskDescription, taskTag, subtasks, Int(timeAsString)!)
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
                    ForEach(getDaysEntry(items: entries, initializeFunc: self.initializeConquer, newEntryFunc: self.addEntry).tasks!) { entry in
                        todoRow(taskTitle: entry.taskTitle, tagTitle: entry.tag, duration: entry.duration, taskDescription: entry.taskDescription, taskInstructions: entry.subTasks, todoComplete: entry.completed, todoUUID: entry.id, toggleFunction: self.toggleTask,toggleSubtaskFunction: self.toggleSubTask, timestamp: getDateAsString(dateObject: date), taskPriority: entry.taskPriority)
                    }
                    .onDelete(perform: deleteTodo)
                    
                }
            }
        }
    }
    
    func deleteTodo(at offset: IndexSet) {
        self.entries[self.entries.firstIndex(of: getDaysEntry(items: entries, initializeFunc: self.initializeConquer, newEntryFunc: self.addEntry))!].tasks?.remove(atOffsets: offset)
        try? ourModelContext.save()
    }
    
    
    func getDaysEntry(items: [Item], initializeFunc: () -> Void, newEntryFunc: (String) -> Item) -> Item {
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

struct todoRow: View {
    @State var isOn = false
    var taskTitle: String
    var tagTitle: String
    var duration: Int
    var taskDescription: String
    var taskInstructions: [SubTask]
    @State var todoComplete: Bool
    var todoUUID: UUID
    var toggleFunction: (String, UUID) -> Bool
    var toggleSubtaskFunction: (String, UUID, UUID) -> Bool
    var timestamp: String
    var taskPriority: Int
    var body: some View {
        HStack{
            Button(action: toggleCheckbox, label: {
                if (todoComplete) {
                    Image(systemName: "checkmark.circle")
                } else {
                    Image(systemName: "circle")
                }
            })
            .buttonStyle(.plain)
            
            Spacer()
            
            NavigationLink {
                todoDetailedView(taskTitle: taskTitle, taskDescription: taskDescription, instructions: taskInstructions, toggleFunction: self.toggleSubtaskFunction, timestamp: timestamp, todoUUID: todoUUID)
            } label: {
                HStack{
                    Text(taskTitle)
                    Spacer()
                    Text(tagTitle)
                        .background(.red)
                        .foregroundStyle(.white)
                        .safeAreaPadding(.horizontal, 5)
                    Text(self.getTimeAsString())
                        .foregroundStyle(.white)
                        .background(.purple)
                        .safeAreaPadding(.horizontal, 5)
                }
            }
            
        }
        .lineLimit(1)
        .minimumScaleFactor(0.01)
    }
    
    func getTimeAsString() -> String {
        var ourTaskPriorityString = String(self.taskPriority)
        while (ourTaskPriorityString.count < 4) {
            ourTaskPriorityString = "0" + ourTaskPriorityString
        }
        return (ourTaskPriorityString.prefix(2) + ":" + ourTaskPriorityString.suffix(2))
    }
    
    func toggleCheckbox() {
        if (self.toggleFunction(timestamp, todoUUID) == true) {
            self.todoComplete = true
        } else {
            self.todoComplete = false
        }
    }
}

struct todoDetailedView: View {
    var taskTitle: String
    var taskDescription: String
    @State var instructions: [SubTask]
    var toggleFunction: (String, UUID, UUID) -> Bool
    var timestamp: String
    var todoUUID: UUID
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
                    ForEach($instructions, id: \.self) { instruction in
                        Button(action: {
                            toggleFunction(timestamp, todoUUID, instruction.id)
                            instructions[instructions.firstIndex(of: instruction.wrappedValue)!].completed.toggle()
                            
                        }, label: {
                            HStack {
                                if (instruction.wrappedValue.completed == true) {
                                    Image(systemName: "checkmark.circle")
                                } else {
                                    Image(systemName: "circle")
                                }
                                Text(instruction.wrappedValue.taskText)
                            }
                            .tint(.secondary)
                            .padding(.horizontal)
                        })
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
