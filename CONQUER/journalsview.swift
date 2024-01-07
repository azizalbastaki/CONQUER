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
                
                ForEach($journals, id: \.self) { journal in
                    TextField("What is the title of your entry?", text: journal.journalTitle)
                    TextField("Start writing here...", text: journal.journalText)
                }
                .onChange(of: self.journals, {
                    self.entries[self.getIndex()!].journals = self.journals
                    try? ourModelContext.save()
                })

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
                print("Index chosen is")
                print(entries[1].timestamp)
                return index
            }
            index = index + 1
        }
        return nil
    }
}
