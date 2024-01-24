//
//  settingsview.swift
//  CONQUER
//
//  Created by Abdulaziz Albastaki on 02/01/2024.
//

/*
 //
 ** TO DO LIST **
 Add To Be List
 Add To Be List Journal option
 Add routines and their options
 Turn this into a navigation stack
 View Past ratings system
 Add option to export all date into
 
 ** POST RELEASE LIST **
 
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
                            Text("")
                        } label: {
                            Text("View ratings from past days")
                        }
                        
                    }
                    
                }
                
                Text("Settings")
                Button(action: deletething, label: {
                    Text("Delete all data and crash")
                })
            }
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
    
    func getRatings() {
        //
    }
    
}

struct ratingItem {
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
