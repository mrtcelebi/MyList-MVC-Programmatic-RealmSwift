//
//  Item.swift
//  ToDoList
//
//  Created by Catalina on 9.08.2020.
//  Copyright © 2020 Catalina. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var done: Bool = false
}
