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
    @Query private var items: [Item]
    
    var body: some View {
        TabView {
            todaystodoview()
                .tabItem { Label("Today's Tasks", systemImage: "dot.scope") }
            Text("Journal")
                .tabItem { Label("Journal", systemImage: "book.fill") }
            Text("Projects")
                .tabItem { Label("Projects", systemImage: "hammer.fill") }
            Text("Settings")
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        
        
    }
    
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
