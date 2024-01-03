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
    var addFunction: (String, Date, Int, String, String) -> Void
    var initializeConquer: () -> Void
    var addEntry: (String) -> Item
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
                        //                        Button(action: deletething, label: {Image(systemName: "calendar")
                        //                                .padding(.horizontal)
                        //                        })
                        //
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
                                
                                Button(action: {
                                    self.addFunction(taskTitle, date, taskDuration,taskDescription, taskTag)
                                    self.taskTitle = ""
                                    self.taskDescription = ""
                                    self.taskDuration = 0
                                    self.date = Date.now
                                    self.taskTag = ""
                                },
                                       label: {
                                    Text("Add Task")
                                        .padding(.trailing)
                                        .font(.system(size: 25))
                                    
                                    
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
                        todoRow(taskTitle: entry.taskTitle, tagTitle: entry.tag, duration: entry.duration)
                        
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
    
}
func dothing() {
    print("Hello")
}

struct todoRow: View {
    @State var isOn = false
    var taskTitle: String
    var tagTitle: String
    var duration: Int
    var body: some View {
        HStack{
            Button(action: dothing, label: {
                Image(systemName: "circle")
            })
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
        .lineLimit(1)
        .minimumScaleFactor(0.01)
    }
}

struct todoDetailedView: View {
    var taskTitle: String
    var taskDescription: String
    var body: some View {
        VStack {
            Text(taskTitle)
                .font(.title)
                .padding(.horizontal)
                .bold()
            Text(taskDescription)
                .font(.subheadline)
                .padding(.horizontal)
                
        }
    }
}


func getTodaysDate() -> String {
    getDateAsString(dateObject: Date.now)
}

func getDateAsString(dateObject: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    return formatter.string(from: dateObject)
}
//#Preview {
//    todaystodoview()
//}
