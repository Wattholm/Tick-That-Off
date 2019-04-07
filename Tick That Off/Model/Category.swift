//
//  Category.swift
//  Tick That Off
//
//  Created by Kevin Joseph Mangulabnan on 21/01/2019.
//  Copyright © 2019 Kevin Joseph Mangulabnan. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var bgColor: String = ""
    let items = List<Item>()
}
