//
//  Character.swift
//  ff14app
//
//  Created by mannyadmin on 4/8/19.
//  Copyright © 2019 Stabbity Style Industries. All rights reserved.
//

import Foundation

class Character {
    var name: String
    var id: Int
    var server: String
    
    init(name: String, id: Int, server: String) {
        self.name = name
        self.id = id
        self.server = server
    }
}
