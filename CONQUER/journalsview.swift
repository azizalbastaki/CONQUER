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
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Journal")
                        .font(.title)
                        .padding(.horizontal)
                        .bold()
                    Spacer()
                }
                HStack {
                    Text(getTodaysDate())
                        .font(.subheadline)
                        .padding(.horizontal)
                        .bold()
                }
                
                HStack {
                    Text("Your rating for today: ")
                    TextField("Rate your Day", value: $entries[self.getIndex()!].entryRating, formatter: self.getNumberFormatter())
                        .foregroundStyle(.white)
                        .background(.blue)
                        .keyboardType(.decimalPad)
                    Spacer()
                    
                }
                .padding()
                
                ScrollView {
                    
                    ForEach($journals) { $journal in
                        TextField("What is the title of your entry?", text: $journal.journalTitle)
                            .bold()
                        TextField("Start writing here...", text: $journal.journalText)
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
        } )
        
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
