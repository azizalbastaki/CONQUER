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
            todaystodoview(ourModelContext: modelContext, entries: items, addFunction: self.addToDoTask, initializeConquer: self.initializeConquer, addEntry: self.addNewEntry)
                .tabItem { Label("Today's Tasks", systemImage: "dot.scope") }
            Text("Journal")
                .tabItem { Label("Journal", systemImage: "book.fill") }
            Text("Projects")
                .tabItem { Label("Projects", systemImage: "hammer.fill") }
            settingsview(ourModelContext: modelContext, initalizeConquer: self.initializeConquer)
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
            modelContext.insert(tobelist)
            modelContext.insert(routinelist)
            modelContext.insert(projectlist)
            modelContext.insert(taglist)
            try? modelContext.save()
        }
    }
    
    func addToDoTask(taskTitle: String, dueBy: Date, minutes: Int, taskDescription: String, tagTitle: String) {
        withAnimation {
            let newToDo = ToDoTask(completed: false, deadline: dueBy, duration: minutes, taskTitle: taskTitle, taskDescription: taskDescription, tag: tagTitle, routineSetting: .none)
            
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
            
        }
    }
    
    func addNewEntry(day: String) -> Item {
        print("New Entry Being Added!")
        var newEntry = Item(itemType: .dailyEntry)
        newEntry.timestamp = day
        
        if (getTodaysDate() == day || Date.now < getDateFromString(dateString: day)) {
            
            
            let dayOfTheWeek = day.components(separatedBy: ",")[0]
            if (dayOfTheWeek == items[0].timestamp) {
                newEntry.journals!.append(journal(journalTitle: "Reflect on your To-Be list", journalText: "*ADD TO-BEs HERE*"))
            }
            
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
            
            for routine in items[1].tasks! {
                if (routine.routineSetting == .daily || routine.routineSetting == dayOfTheWeekEnum) {
                    newEntry.tasks!.append(routine)
                }
            }
        }
        
        modelContext.insert(newEntry)
        try? modelContext.save()
        return newEntry
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
