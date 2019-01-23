//
//  Item.swift
//  Tick That Off
//
//  Created by Kevin Joseph Mangulabnan on 21/01/2019.
//  Copyright © 2019 Kevin Joseph Mangulabnan. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var checked: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
