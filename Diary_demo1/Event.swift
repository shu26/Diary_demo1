//
//  Event.swift
//  Diary_demo1
//
//  Created by shu26 on 2019/06/20.
//  Copyright © 2019 shu26. All rights reserved.
//

import Foundation
import RealmSwift

class Event: Object {
    
    @objc dynamic var date: String = ""
    @objc dynamic var event: String = ""
}
