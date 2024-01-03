//
//  Item.swift
//  CONQUER
//
//  Created by Abdulaziz Albastaki on 30/12/2023.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Item {
    var timestamp: String?
    var itemType: ItemType?
    var journals: [journal]?
    var tasks: [ToDoTask]?
    var entryRating: Double?
    init(itemType: ItemType) {
        self.itemType = itemType
        self.timestamp = getTodaysDate()
        self.tasks = []
        self.journals = []
        self.entryRating = 6.0
    }
}

enum ItemType: Codable, Hashable{
    case tobelist
    case dailyEntry
    case routines
    case projects
    case taglist
}

struct journal: Codable, Hashable {
    var journalTitle: String
    var journalText: String
}

struct SubTask: Hashable, Codable, Identifiable {
    var id = UUID()
    var taskText: String
    var completed: Bool = false
    
}

struct ToDoTask: Hashable, Codable, Identifiable {
    var id = UUID()
    var completed: Bool
    var deadline: Date
    var duration: Int
    var taskTitle: String
    var taskDescription: String
    var taskPriority: Int = 1
    var tag: String
    //var subTasks: [SubTask]
    var routineSetting: RoutineSetting
}

enum RoutineSetting: Hashable, Codable {
    case daily, monday, tuesday, wednesday, thursday, friday, saturday, sunday, none
}
