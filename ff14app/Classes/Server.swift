//
//  Server.swift
//  ff14app
//
//  Created by mannyadmin on 3/29/19.
//  Copyright © 2019 Stabbity Style Industries. All rights reserved.
//

import Foundation

class Server {
    var serverName: String
    var status: String
    
    init(serverName: String, status: String) {
        self.serverName = serverName
        self.status = status
    }
}
