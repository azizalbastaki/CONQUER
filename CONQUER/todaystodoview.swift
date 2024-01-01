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
    //var entries: () -> [Item]
    var entries: [Item]
    var addFunction: (String, Date, Int, String, String) -> Void
    var initializeConquer: () -> Void
    var addEntry: (String) -> Void
    @State var taskTitle = ""
    @State var taskDescription = ""
    @State var taskDuration = 30
    @State var date = Date.now
    @State var taskTag = ""
    
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Today's Tasks")
                        .font(.title)
                        .padding(.horizontal)
                        .bold()
                    
                    Spacer()
                    Button(action: dothing, label: {Image(systemName: "calendar")
                            .padding(.horizontal)
                    })
                    
                    NavigationLink {
                        Form {
                            Section {
                                TextField("Task Name", text: self.$taskTitle)
                            }
                            
                            Section {
                                TextField("Description of Task. For example, Why are you doing this Task? How will this help you achieve a long term goal?", text: self.$taskDescription)
                                    .lineLimit(5, reservesSpace: true)
                            }
                            
                            Section {
                                TextField("In minutes, how long will this task take?", value: self.$taskDuration, formatter: NumberFormatter())
                                    .keyboardType(.numberPad)
                            }
                            
                            Section {
                                DatePicker(selection: $date, in: Date.now..., displayedComponents: .date) {
                                    Text("Task set for \(DateFormatter().string(from: date))")
                                }
                            
                            }
                            Section {
                                TextField("Tag this Task", text: $taskTag)
                            }
                            
                            Button(action: {
                                self.addFunction(taskTitle, date, taskDuration,taskDescription, taskTag)
                                self.taskTitle = ""
                                self.taskDescription = ""
                                self.taskDuration = 30
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
                
                HStack {
                    Text(getTodaysDate())
                        .padding(.horizontal)
                    Spacer()
                }
            }
        .padding(.horizontal)
            List {
                ForEach(getTodaysEntry(items: entries, initializeFunc: self.initializeConquer, newEntryFunc: self.addEntry).tasks) { entry in
                    todoRow(taskTitle: entry.taskTitle, tagTitle: taskTag, duration: taskDuration)
                    
                }
            }
        }
    }
    
    
    func getTodaysEntry(items: [Item], initializeFunc: () -> Void, newEntryFunc: (String) -> Void) -> Item {
        if (searchForEntry(items: items, entryTimestamp: getTodaysDate()) != nil) {
            return searchForEntry(items: items, entryTimestamp: getTodaysDate())!
        }
        
        else {
            if (items.count == 0) {
                initializeFunc()
            }
            newEntryFunc(getTodaysDate())
            return searchForEntry(items: items, entryTimestamp: getTodaysDate())!
        }
    }

    func searchForEntry(items: [Item], entryTimestamp: String) -> Item? {
        for item in items {
            if (item.timestamp == getTodaysDate()) {
                return item
            }
        }
        return nil
    }


}

struct todoRow: View {
    @State var isOn = false
    var taskTitle: String
    var tagTitle: String
    var duration: Int
    var body: some View {
        HStack{
            Button(action: dothing, label: {
                Image(systemName: "checkmark.circle")
            })
            Text(taskTitle)
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

func dothing() {
    print("Hello")
}

func getTodaysDate() -> String {
    let formatter = DateFormatter()
    formatter.dateStyle = .full
    return formatter.string(from: .now)
}
//#Preview {
//    todaystodoview()
//}
