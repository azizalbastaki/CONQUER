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
    var timestamp: String
    var itemType: ItemType
    var journals = [journal]()
    init(itemType: ItemType) {
        self.itemType = itemType
        self.timestamp = getTodaysDate()
    }
}

enum ItemType: Codable, Hashable{
    case tobelist
    case dailyEntry
    case routines
    case projects
}

struct journal: Codable, Hashable {
    var journalTitle: String
    var journalText: String
}

class SubTask {
    var completed: Bool
    var deadline: Date
    //    var tag: String
    //    var tagColor: Color
    var duration: Int
    var taskTitle: String
    var taskDescription: String
    
    init(title: String, deadline : Date?, duration: Int?, description: String?) {
        self.taskTitle = title
        self.completed = false
        self.deadline = Date(timeIntervalSinceNow: 3153600000)
        self.duration = 1
        self.taskDescription = ""
        if (deadline != nil) {
            self.deadline = deadline!
        }
        if (duration != nil) {
            self.duration = duration!
        }
        if (description != nil) {
            self.taskDescription = description!
        }
    }
}

class ToDoTask: SubTask {
    var tag: String
    var tagColor: Color
    var subTasks: [SubTask]
    
    init(title: String, deadline : Date?, duration: Int?, description: String?, tagTitle: String, color: Color) {
        self.tag = tagTitle
        self.tagColor = color
        self.subTasks = []
        super.init(title: title, deadline: deadline, duration: duration, description: description)
        
    }
}
