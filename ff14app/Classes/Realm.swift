//
//  Realm.swift
//  ff14app
//
//  Created by mannyadmin on 3/29/19.
//  Copyright © 2019 Stabbity Style Industries. All rights reserved.
//

import Foundation

class Realm {
    var realmName: String
    var servers: [Server] = []
    
    init(realmName: String) {
        self.realmName = realmName
    }
}
