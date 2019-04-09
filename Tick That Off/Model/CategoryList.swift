//
//  CategoryList.swift
//  Tick That Off
//
//  Created by Kevin Joseph Mangulabnan on 08/04/2019.
//  Copyright © 2019 Kevin Joseph Mangulabnan. All rights reserved.
//

import Foundation
import RealmSwift

class CategoryList: Object {
    let items = List<Category>()
}
