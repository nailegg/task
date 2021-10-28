//
//  Task.swift
//  toys
//
//  Created by 이상현 on 2021/10/22.
//

import Foundation
import Combine


struct Task: Identifiable, Codable{
    var id = String()
    var content = String()
    var due = Date()
}
struct getTask: Identifiable, Codable{
    var _id : String
    var id : String
    var content : String
    var due : String
    var __v : Int
}
struct User: Identifiable, Codable{
    var id = String()
}
struct getUser: Identifiable, Codable{
    var _id : String
    var id : String
    var __v : Int
}
class TaskViewModel: ObservableObject{
    @Published var tasks = [Task]()
}
