//
//  settingsview.swift
//  CONQUER
//
//  Created by Abdulaziz Albastaki on 02/01/2024.
//

/*
 //
 ** TO DO LIST **
 Add To Be List Journal option (day of week)
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
    @State var showAlert: Bool = false
    @State var addToBeTitle = ""
    @State var addToBeDesc = ""
    @State var tobes: [journal] = []
    @State var entries: [Item]
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
                            ForEach(self.getRatings(), id: \.self) { rating in
                                HStack {
                                    Text(rating.timestamp)
                                        .padding(.horizontal)
                                    Spacer()
                                    Text(String(rating.rating))
                                        .padding([.horizontal], 30)
                                        .background(self.getBgColor(dayRating: rating.rating))
                                }
                                
                            }
                            .padding()
                            Spacer()
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
                    
                    
                    
                }
                
                Text("Settings")
                Button(action: deletething, label: {
                    Text("Delete all data and crash")
                })
            }
        }.onAppear(perform: {
            tobes = []
            let listItem = self.getToBeList()
            for toBe in listItem!.journals! {
                tobes.append(journal(journalTitle: toBe.journalTitle, journalText: toBe.journalText))
            }
        })
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
    
    func getRatings() -> [ratingItem] {
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
    
    func deleteToBe(at offsets: IndexSet) {
        tobes.remove(atOffsets: offsets)
    }
    
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


//
//#Preview {
//    settingsview()
//}
