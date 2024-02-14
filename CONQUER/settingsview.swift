//
//  settingsview.swift
//  CONQUER
//
//  Created by Abdulaziz Albastaki on 02/01/2024.
//

/*
 //
 ** TO DO LIST **
 Add routines and their options
 Add option to export all date into
 
 ** POST RELEASE TODO LIST **
 
 -Delete old entries
 -Change theme
 -Language
 -OpenAPI Key Slot
 */
import SwiftUI
import SwiftData
struct settingsview: View {
    var ourModelContext: ModelContext
    var initalizeConquer: () -> Void
    var getEntries: () -> [Item]
    @State var showAlert: Bool = false
    @State var addToBeTitle = ""
    @State var addToBeDesc = ""
    @State var tobes: [journal] = []
    @State var entries: [Item]
    @State var routines: [ToDoTask] = []
    var weeklyoptions = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Every day"]
    var weeklyoptionsEnum: [RoutineSetting] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .daily]
    @State var selectedToBeDay = "Every day"
    
    // Routine Settings stuff
    
    @State var taskTitle = ""
    @State var taskDescription = ""
    @State var taskDuration = 10
    @State var dayOfWeek = RoutineSetting.daily
    @State var taskTag = ""
    @State var timeSelected = Date.now
    @State var subtasks: [SubTask] = []
    @State var newInstruction: String = ""
    
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack{
                    Text("Settings")
                        .bold()
                        .font(.title)
                        .padding()
                    Spacer()
                }
                List {
                    Section("Ratings") {
                        NavigationLink {
                            ScrollView {
                                ForEach(self.getRatings(), id: \.self) { rating in
                                    if (getDateFromString(dateString: rating.timestamp) <= Date.now) {
                                        HStack {
                                            Text(rating.timestamp)
                                                .padding(.horizontal)
                                            Spacer()
                                            Text(String(rating.rating))
                                                .padding([.horizontal], 30)
                                                .background(self.getBgColor(dayRating: rating.rating))
                                        }
                                    }
                            }
                        }
                            .padding()
                        } label: {
                            Text("View ratings from past days")
                        }
                        
                    }
                    
                    Section("To Be List") {
                        ForEach(self.$tobes, id: \.self) { $toBe in
                            Text(toBe.journalTitle)
                            
                        }
                        .onDelete(perform: deleteToBe)
                        
                        
                        Button("Add Trait") {
                            showAlert = true
                        }
                        .alert("Add New Trait", isPresented: $showAlert, actions: {
                            TextField("To Be Title", text: $addToBeTitle)
                            TextField("Elaborate", text: $addToBeDesc)
                            
                            Button("Add", action: {
                                tobes.append(journal(journalTitle: addToBeTitle, journalText: addToBeDesc))
                                self.addToBeTitle = ""
                                self.addToBeDesc = ""
                                self.showAlert = false
                            })
                            
                            Button("Cancel", role: .cancel, action: {
                                self.addToBeDesc = ""
                                self.addToBeTitle = ""
                                self.showAlert = false
                            })
                        })
                        
                    }
                    
                    .onChange(of: self.tobes, {
                        var tobeIndex = self.getToBeList()
                        tobeIndex?.journals = self.tobes
                        try? ourModelContext.save()
                    })
                    
                    Section("Journalling") {
                        Picker("Review To-be list on", selection: $selectedToBeDay) {
                            ForEach(weeklyoptions, id: \.self) {
                                Text($0)
                            }
                        }
                        
                        .onChange(of: self.selectedToBeDay, {
                            var tobeIndex = self.getToBeList()
                            tobeIndex?.timestamp = self.selectedToBeDay
                            try? ourModelContext.save()
                        })
                    }
                    
                    Section("Routines") {
                        ForEach(self.$routines, id: \.self) { $routine in
                            HStack {
                                Text(routine.taskTitle)
                                Spacer()
                                Text(routine.routineSetting.description)
                            }
                            //.padding()
                        }
                        .onDelete(perform: deleteRoutine)
                        
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
                                
                                Section("Day of Task") {
                                    Picker("Set day for: ", selection: $dayOfWeek) {
                                        ForEach(weeklyoptionsEnum, id: \.self) {
                                            Text($0.description)
                                        }
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
                                        ForEach(self.$subtasks, id: \.self) { $subtask in
                                            Text($subtask.taskText.wrappedValue)
                                        }
                                        .onDelete(perform: deleteSubtask)
                                        HStack {
                                            TextField("Keep it small and concise", text: $newInstruction)
                                            
                                            Button(action: {
                                                self.subtasks.append(SubTask(taskText: self.newInstruction))
                                                self.newInstruction = ""
                                            }, label: {
                                                Text("Add")
                                                    .padding(.trailing)
                                                
                                            })
                                        }
                                    }
                                    
                                }
                                
                                Button(action: {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "HHmm"
                                    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                                    let timeAsString = dateFormatter.string(from: self.timeSelected)
                                    let newTask = ToDoTask(completed: false, deadline: .now, duration: taskDuration, taskTitle: taskTitle, taskDescription: taskDescription, taskPriority: Int(timeAsString)!, tag: taskTag, subTasks: subtasks, routineSetting: dayOfWeek)
                                    
                                    for entry in entries {
                                        
                                        /*
                                         A lot to unpack in the if statement below, but here it is:
                                         -Item must be a daily entry
                                         -Daily entry must be on the same weekday as its assigned routine setting OR if its routine setting is set to  'daily'
                                         -Item must be an entry of today's date OR one from a future date
                                         */
                                        
                                        if entry.itemType == .dailyEntry {

                                        }
                                        if (entry.itemType == .dailyEntry) &&
                                            ((entry.timestamp!.components(separatedBy: ",")[0] == self.dayOfWeek.description) || self.dayOfWeek == RoutineSetting.daily) &&
                                            (entry.timestamp! == getTodaysDate() || getDateFromString(dateString: entry.timestamp!) > Date.now)
                                        {
                                            entry.tasks?.append(newTask)
                                        }
                                    }
                                    
                                    self.newInstruction = ""
                                    self.taskTitle = ""
                                    self.taskDescription = ""
                                    self.taskDuration = 10
                                    self.subtasks = []
                                    self.taskTag = ""
                                    self.getRoutineList()?.tasks?.append(newTask)
                                    
                                    try? ourModelContext.save()
                                    
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
                            Text("Add New Routine")
                                .padding(.trailing)
                            //.font(.system(size: 25))
                        }
                    }
                    //
                    //                    Text("Settings")
                    //                    Button(action: deletething, label: {
                    //                        Text("Delete all data and crash")
                    //                    })
                }
            }.onAppear(perform: {
                self.entries = self.getEntries()
                tobes = []
                let listItem = self.getToBeList()
                for toBe in listItem!.journals! {
                    tobes.append(journal(journalTitle: toBe.journalTitle, journalText: toBe.journalText))
                }
                
                self.selectedToBeDay = (self.getToBeList()?.timestamp)!
                
                routines = (self.getRoutineList()?.tasks!)!
                
                
            })
        }
    }
    func deletething() {
        do {
            try ourModelContext.delete(model: Item.self)
            initalizeConquer()
        } catch {
            print("Could not delete.")
        }
    }
    
    func getBgColor(dayRating: Double) -> Color {
        if (0.00...4.00 ~= dayRating) {
            return .red
        }
        else if (6.01...8.99 ~= dayRating) {
            return .green
        }
        
        else if (dayRating > 8.99) {
            return .blue
        }
        else {
            return .orange
        }
    }
    
    func getRatings() -> [ratingItem] { // Filter out future ratings
        var ratings: [ratingItem] = []
        for entry in entries {
            if (entry.itemType == .dailyEntry) {
                ratings.append(ratingItem(rating: entry.entryRating ?? 6.0, timestamp: entry.timestamp!))
            }
        }
        
        ratings = ratings.sorted { rating1, rating2 in
            getDateFromString(dateString: rating1.timestamp) > getDateFromString(dateString: rating2.timestamp)
        }
        
        return ratings
    }
    
    func getToBeList() -> Item? {
        for itemObject in self.entries {
            if (itemObject.itemType == .tobelist) {
                return itemObject
            }
        }
        return nil
    }
    
    func getRoutineList() -> Item? {
        for itemObject in self.entries {
            if (itemObject.itemType == .routines) {
                return itemObject
            }
        }
        return nil
    }
    
    func deleteToBe(at offsets: IndexSet) {
        tobes.remove(atOffsets: offsets)
    }
    
    func deleteRoutine(at offsets: IndexSet) {
        let routinesToDelete = offsets.map { self.routines[$0] }
        for routine in routinesToDelete {
            for entry in entries {
                if (entry.itemType == .dailyEntry) {
                    if ((routine.routineSetting == .daily) || (routine.routineSetting.description == entry.timestamp?.components(separatedBy: ",")[0])) &&
                        (entry.timestamp == getTodaysDate() || getDateFromString(dateString: entry.timestamp!) > Date.now)
                    {
                        if (entry.tasks!.contains(routine)) {
                            entry.tasks?.remove(at: (entry.tasks?.firstIndex(of: routine))!)
                        }
                    }
                }
            }
            getRoutineList()?.tasks?.remove(at: (getRoutineList()?.tasks?.firstIndex(of: routine))!)
        }
        routines.remove(atOffsets: offsets)
        try? ourModelContext.save()
    }
    func deleteSubtask(at offsets: IndexSet) {
        subtasks.remove(atOffsets: offsets)
    }
    
    
    struct ratingItem: Hashable {
        var id = UUID()
        var rating: Double
        var timestamp : String
        
        init(rating: Double, timestamp: String) {
            self.rating = rating
            self.timestamp = timestamp
        }
    }
}

//
//#Preview {
//    settingsview()
//}
