//
//  journalsview.swift
//  CONQUER
//
//  Created by Abdulaziz Albastaki on 04/01/2024.
//

import SwiftUI
import SwiftData

struct journalsview: View {
    var ourModelContext: ModelContext
    @State var entries: [Item]
    @State var journals: [journal] = []
    @State var todaysRating: Double = 6.0
    var getEntries: () -> [Item]

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Journal")
                        .font(.title)
                        .padding(.horizontal)
                        .bold()
                    
                    Spacer()
                    
                    NavigationLink {
                        Text("Past Entries")
                            .font(.title)
                            .bold()
                            .padding()
                        List {
                            ForEach(self.getPastJournals()) { oldJournal in
                                NavigationLink {
                                    VStack{
                                        Text(oldJournal.journalTitle)
                                            .font(.title)
                                            .padding()
                                            .bold()
                                        Text(oldJournal.journalText)
                                            .padding()
                                        Spacer()
                                    }
                                } label: {
                                    HStack {
                                        Text(oldJournal.journalTitle)
                                        Spacer()
                                    }
                                }
                            }
                        }
                        
                    } label: {
                        Image(systemName: "book.pages.fill")
                            .padding(.horizontal)
                    }
                    
                    Button(action: {self.addJournal()}, label: {
                        Text("+")
                            .padding(.trailing)
                            .font(.system(size: 25))
                    })
                }
                HStack {
                    Text(getTodaysDate())
                        .font(.subheadline)
                        .bold()
                        .minimumScaleFactor(0.01)
                        .padding(.horizontal)
                    Spacer()
                }
                HStack {
                    Text("Your rating for today: ")
                    TextField("Rate your Day", value: $todaysRating, formatter: self.getNumberFormatter())
                        .padding(.horizontal)
                        .foregroundStyle(.secondary)
                        .keyboardType(.decimalPad)
                        .onChange(of: self.todaysRating, {
                            if (self.todaysRating <= 0) {
                                self.todaysRating = 0.1
                            }
                            else if (self.todaysRating >= 10.0) {
                                self.todaysRating = 9.9
                            }
                            self.entries[self.getIndex()!].entryRating = self.todaysRating
                            try? ourModelContext.save()
                        }
                        )
                    Spacer()
                    
                    
                }
                .padding(.horizontal)
                
                ScrollView {
                    
                    ForEach(self.$journals) { $journal in
                        TextField("What is the title of your entry?", text: $journal.journalTitle)
                            .bold()
                        TextField("Start writing here...", text: $journal.journalText, axis: .vertical)
                            .padding(.bottom)
                        
                    }
                    .padding()
                    .onChange(of: self.journals, {
                        self.entries[self.getIndex()!].journals = self.journals
                        try? ourModelContext.save()
                        
                    })
                }
            }
        }
        .onAppear( perform: {
            journals = getJournals()
            print("CALLED")
            print(getJournals())
            self.todaysRating = entries[self.getIndex()!].entryRating!
            
            if (self.getToBesItem().timestamp == getTodaysDate().components(separatedBy: ",")[0]) || (self.getToBesItem().timestamp == "Every day") {
                var containsToBeReflection = false
                for journal in journals {
                    if journal.journalTitle.contains("To Be List Reflection -") {
                        containsToBeReflection = true
                    }
                }
                
                if (containsToBeReflection == false) {
                    self.addReflectionJournal()
                }
            }
        } )
        
        .onDisappear(perform: {
            self.entries[self.getIndex()!].journals = journals.filter { journal in
                if (journal.journalText == "" && journal.journalTitle == "") {
                    return false
                } else {
                    return true
                }
            }
            try? ourModelContext.save()
        }
        )
    }
    
    func getPastJournals() -> [journal] {
        var journalsCollected: [journal] = []
        var entriesToQueryJournals = entries

        entriesToQueryJournals = entriesToQueryJournals.filter { entryInstance in
            if (entryInstance.itemType != .dailyEntry) {
                return false
            }
            else {
                if (getDateFromString(dateString:entryInstance.timestamp!) > getDateFromString(dateString: getTodaysDate())) {
                    return false
                }
                
                else {
                    return true
                }
            }
            
        }
        
        entriesToQueryJournals = entriesToQueryJournals.sorted { entry1, entry2 in
            getDateFromString(dateString: entry1.timestamp!) > getDateFromString(dateString: entry2.timestamp!)
        }
        
        for entry in entriesToQueryJournals {
            if (entry.timestamp != getTodaysDate()) {
                for journal in entry.journals! {
                    journalsCollected.append(journal)
                }
            }
        }
        
        return journalsCollected
    }
    
    func addJournal() {
        self.entries[self.getIndex()!].journals?.append(journal(journalTitle: "", journalText: ""))
        try? ourModelContext.save()
        journals = getJournals()
        
    }
    
    func addReflectionJournal() {
        self.entries[self.getIndex()!].journals?.append(journal(journalTitle: "To Be List Reflection - \(getDateAsShortString(dateObject: Date.now))", journalText: self.getToBes()))
        try? ourModelContext.save()
        journals = getJournals()
    }
    
    func getToBesItem() -> Item {
        var entrieslist = self.getEntries()
        var tobearray = entrieslist.filter { entryItem in
            if (entryItem.itemType == .tobelist) {
                return true
            }
            else {
                return false
            }
        }
        
        return tobearray[0]
    }
    
    func getToBes() -> String {
        
        var tobeString: String = "Write a reflection on your progress in achieving the following qualities: \n\n"
        for tobe in self.getToBesItem().journals! {
            tobeString = tobeString + tobe.journalTitle + " - \n\n"
        }
        return tobeString
        
    }
    
    func getJournals() -> [journal] {
        return self.entries[self.getIndex()!].journals!
    }
    
    func getIndex() -> Int? {
        var index = 0
        for entry in self.getEntries() {
            if (entry.timestamp == getTodaysDate()) {
                return index
            }
            index = index + 1
        }
        return nil
    }
    
    func getNumberFormatter() -> NumberFormatter {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .decimal
        numFormatter.minimumFractionDigits = 1
        numFormatter.maximumFractionDigits = 1
        return numFormatter
    }
}
