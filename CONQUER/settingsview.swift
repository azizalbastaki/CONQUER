//
//  settingsview.swift
//  CONQUER
//
//  Created by Abdulaziz Albastaki on 02/01/2024.
//

import SwiftUI
import SwiftData
struct settingsview: View {
    var ourModelContext: ModelContext
    var initalizeConquer: () -> Void
    var body: some View {
        VStack {
            Text("Settings")
            Button(action: deletething, label: {
                Text("Delete all data and crash")
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
    
}
//
//#Preview {
//    settingsview()
//}
