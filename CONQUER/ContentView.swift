//
//  ContentView.swift
//  CONQUER
//
//  Created by Abdulaziz Albastaki on 30/12/2023.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var items: [Item]
    
    var body: some View {
        TabView {
            todaystodoview(ourModelContext: modelContext, entries: items, addFunction: self.addToDoTask, initializeConquer: self.initializeConquer, addEntry: self.addNewEntry, toggleTask: self.toggleTask, toggleSubTask: self.toggleSubTask)
                .tabItem { Label("Today's Tasks", systemImage: "dot.scope") }
            journalsview(ourModelContext: modelContext, entries: items)
                .tabItem { Label("Journal", systemImage: "book.fill") }
//            projectview()                 *** PROJECTS TO BE ADDED POST RELEASE ***
//                .tabItem { Label("Projects", systemImage: "hammer.fill") }
            settingsview(ourModelContext: modelContext, initalizeConquer: self.initializeConquer, entries: items)
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .onAppear(perform: {initializeConquer()})
        
        
    }
    
    func getItems() -> [Item] {
        return items
    }
    
    func initializeConquer() {
        print("Being Initialized!")
        if (items.count == 0) {
            let tobelist = Item(itemType: .tobelist)
            let routinelist = Item(itemType: .routines)
            let projectlist = Item(itemType: .projects)
            let taglist = Item(itemType: .taglist)
            tobelist.timestamp = ""
            routinelist.timestamp = ""
            projectlist.timestamp = ""
            taglist.timestamp = ""
            modelContext.insert(tobelist)
            modelContext.insert(routinelist)
            modelContext.insert(projectlist)
            modelContext.insert(taglist)
            try? modelContext.save()
            //addNewEntry(day: getTodaysDate())

        }
    }
    
    func addToDoTask(taskTitle: String, dueBy: Date, minutes: Int, taskDescription: String, tagTitle: String, instructions: [SubTask], priority: Int) {
        withAnimation {
            let newToDo = ToDoTask(completed: false, deadline: dueBy, duration: minutes, taskTitle: taskTitle, taskDescription: taskDescription, taskPriority: priority, tag: tagTitle, subTasks: instructions, routineSetting: .none)
            
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            let dueDateAsString = formatter.string(from: dueBy)
            var entryExists = false
            for entry in items {
                if (entry.timestamp == dueDateAsString) {
                    entryExists = true
                    entry.tasks!.append(newToDo)
                }
            }
            
            if (entryExists == false) {
                if (items.count == 0) {
                    self.initializeConquer()
                }
                addNewEntry(day: dueDateAsString)
                items.last!.tasks!.append(newToDo)
            }
            try? modelContext.save()
            var sortedTodos = items.last!.tasks!.sorted { $0.taskPriority < $1.taskPriority }
            items.last!.tasks! = sortedTodos
            try? modelContext.save()
            
        }
    }
    
    func addNewEntry(day: String) -> Item {
        print("New Entry Being Added!")
        var newEntry = Item(itemType: .dailyEntry)
        newEntry.timestamp = day
        print("We're adding a new entry")
        if (getTodaysDate() == day || Date.now < getDateFromString(dateString: day)) {
            print("AND we're adding its components too!")
            
            let dayOfTheWeek = day.components(separatedBy: ",")[0]
            if (dayOfTheWeek == items[0].timestamp) || (items[0].timestamp == "Every day"){
                newEntry.journals!.append(journal(journalTitle: "Reflect on your To-Be list", journalText: "*ADD TO-BEs HERE*"))
            }
            newEntry.journals!.append(journal(journalTitle: "What happened today? - \(getDateAsShortString(dateObject: getDateFromString(dateString: day)))", journalText: ""))
            
            var dayOfTheWeekEnum = RoutineSetting.daily
            
            switch dayOfTheWeek {
            case "Monday":
                dayOfTheWeekEnum = .monday
            case "Tuesday":
                dayOfTheWeekEnum = .tuesday
            case "Wednesday":
                dayOfTheWeekEnum = .wednesday
            case "Thursday":
                dayOfTheWeekEnum = .thursday
            case "Friday":
                dayOfTheWeekEnum = .friday
            case "Saturday":
                dayOfTheWeekEnum = .saturday
            case "Sunday":
                dayOfTheWeekEnum = .sunday
            default:
                print("How did we get here? :3")
            }
        
            for routine in self.getRoutineList().tasks! {
                if (routine.routineSetting == .daily || routine.routineSetting == dayOfTheWeekEnum) {
                    newEntry.tasks!.append(routine)
                }
            }
        }
        modelContext.insert(newEntry)
        try? modelContext.save()
        return newEntry
    }
    
    func findEntryByTimestamp(timestamp: String) -> Item? {
        for entry in items {
            if (entry.timestamp == timestamp) {
                return entry
            }
        }
        return nil
    }
    
    func getTodoByUUID(timestamp: String, todoUUID: UUID) -> ToDoTask? {
        for todo in findEntryByTimestamp(timestamp: timestamp)!.tasks! {
            if (todo.id == todoUUID) {
                return todo
            }
        }
        return nil
        
    }
    
    func getSubTaskByUUID(timestamp: String, todoUUID: UUID, subtaskUUID: UUID) -> SubTask? {
        for subtask in getTodoByUUID(timestamp: timestamp, todoUUID: todoUUID)!.subTasks {
            if (subtask.id == subtaskUUID) {
                return subtask
            }
        }
        return nil
    }
    
    func toggleTask(timestamp: String, todoUUID: UUID) -> Bool {
        let todoTask = getTodoByUUID(timestamp: timestamp, todoUUID: todoUUID)
        let entryIndex = items.firstIndex(of: findEntryByTimestamp(timestamp: timestamp)!)
        let todoIndex = findEntryByTimestamp(timestamp: timestamp)?.tasks?.firstIndex(of: getTodoByUUID(timestamp: timestamp, todoUUID: todoUUID)!)
        if (todoTask!.completed == false) {
            items[entryIndex!].tasks![todoIndex!].completed = true
            try? modelContext.save()
            return true
        } else {
            items[entryIndex!].tasks![todoIndex!].completed = false
            try? modelContext.save()
            return false
        }
    }
    
    func toggleSubTask(timestamp: String, todoUUID: UUID, subtaskUUID: UUID) -> Bool {
        var ourSubTask = getSubTaskByUUID(timestamp: timestamp, todoUUID: todoUUID, subtaskUUID: subtaskUUID)!
        let entryIndex = items.firstIndex(of: findEntryByTimestamp(timestamp: timestamp)!)
        let todoIndex = findEntryByTimestamp(timestamp: timestamp)?.tasks?.firstIndex(of: getTodoByUUID(timestamp: timestamp, todoUUID: todoUUID)!)
        let subtaskIndex = getTodoByUUID(timestamp: timestamp, todoUUID: todoUUID)?.subTasks.firstIndex(of: getSubTaskByUUID(timestamp: timestamp, todoUUID: todoUUID, subtaskUUID: subtaskUUID)!)
        if (ourSubTask.completed == false) {
            items[entryIndex!].tasks![todoIndex!].subTasks[subtaskIndex!].completed = true
            try? modelContext.save()
            return true
        } else {
            items[entryIndex!].tasks![todoIndex!].subTasks[subtaskIndex!].completed = false
            try? modelContext.save()
            return false
        }
    }
    
    func getRoutineList() -> Item {
        var index = 0
        while (items[index].itemType != .routines) {
            index = index + 1
        }
        return items[index]
    }
    
}



// GLOBAL FUNCTIONS

func getTodaysDate() -> String {
    getDateAsString(dateObject: Date.now)
}

func getDateAsString(dateObject: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    return formatter.string(from: dateObject)
}

func getDateAsShortString(dateObject: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter.string(from: dateObject)
}

func getDateFromString(dateString: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    return formatter.date(from: dateString)!
}




//    private func addItem() {
//        withAnimation {
//            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
//        }
//    }
//
//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            for index in offsets {
//                modelContext.delete(items[index])
//            }
//        }
//    }
//}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
