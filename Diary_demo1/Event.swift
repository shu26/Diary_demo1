//
//  Event.swift
//  Diary_demo1
//
//  Created by 海法修平 on 2019/06/20.
//  Copyright © 2019 海法修平. All rights reserved.
//

import Foundation
import RealmSwift

class Event: Object {
    
    @objc dynamic var date: String = ""
    @objc dynamic var event: String = ""
}
