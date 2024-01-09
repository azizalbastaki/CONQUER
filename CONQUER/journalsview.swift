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
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Journal")
                        .font(.title)
                        .padding(.horizontal)
                        .bold()
                    Text(getTodaysDate())
                        .font(.subheadline)
                        .padding(.horizontal)
                        .bold()
                    Spacer()

                }
                HStack {
                    Spacer()
                    Button(action: {self.addJournal()}, label: {
                        Text("+")
                            .padding(.trailing)
                            .font(.system(size: 25))
                    })
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
                .padding()
                
                ScrollView {
                    
                    ForEach(self.$journals) { $journal in
                        TextField("What is the title of your entry?", text: $journal.journalTitle)
                            .bold()
                        TextField("Start writing here...", text: $journal.journalText)
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
        } )
        
    }

    func addJournal() {
        self.entries[self.getIndex()!].journals?.append(journal(journalTitle: "", journalText: ""))
        try? ourModelContext.save()
        journals = getJournals()

    }
    
    func getJournals() -> [journal] {
        return self.entries[self.getIndex()!].journals!
    }
    
    func getIndex() -> Int? {
        var index = 0
        for entry in entries {
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
