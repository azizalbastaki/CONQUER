//
//  projectview.swift
//  CONQUER
//
//  Created by Abdulaziz Albastaki on 16/01/2024.
//

import SwiftUI
import SwiftData

struct projectview: View {
    var ourModelContext: ModelContext
    @State var entries: [Item]
    var body: some View {
        NavigationStack {
            VStack {
                HStack{
                    Text("Projects")
                        .bold()
                        .font(.title)
                        .padding()
                    Spacer()
                }
                
                List {
                    ForEach(self.getProjects()) { project in
                    
                        NavigationLink {
                            VStack {
                                Text(project.timestamp!)
                                    .bold()
                                    .font(.title)
                                    .padding()
                                Text("Project Documents")
                                HStack {
                                    ScrollView(.horizontal) {
                                        ForEach(project.journals!) { journal in
                                            NavigationLink {
                                                VStack {
                                                    Text(journal.journalTitle)
                                                        .font(.title)
                                                        .bold()
                                                        .padding()
                                                }
                                            } label: {
                                                Text(journal.journalTitle)
                                                    .background(.red)
                                                    .clipShape(.capsule)
                                                    .padding()
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack{
                                Text(project.timestamp!)
                                    .padding(.horizontal)
                                Spacer()
                            }
                        }
                        
                    }
                }
            }
        }
    }
    
    func getProjects() -> [Item] {
        var projects: [Item] = []
        for entry in entries {
            if (entry.itemType == .projects) {
                projects.append(entry)
            }
        }
        return projects
    }

}
