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
final class Item: Equatable {
    let id = UUID()
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
    
    static func ==(lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id && lhs.timestamp == rhs.timestamp && lhs.itemType == rhs.itemType && lhs.tasks == rhs.tasks
    }
}

enum ItemType: Codable, Hashable{
    case tobelist
    case dailyEntry
    case routines
    case projects
    case taglist
}

struct journal: Codable, Hashable, Identifiable {
    var id = UUID()
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
    var taskPriority: Int 
    var tag: String
    
    var subTasks: [SubTask]
    var routineSetting: RoutineSetting
}

enum RoutineSetting: Hashable, Codable, CustomStringConvertible {
    case daily, monday, tuesday, wednesday, thursday, friday, saturday, sunday, none
    
    var description : String {
        switch self {
        case .daily: return "Every day"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        case .none: return "Never"
        }
    }
}
