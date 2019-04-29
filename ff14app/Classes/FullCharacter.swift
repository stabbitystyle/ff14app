//
//  FullCharacter.swift
//  ff14app
//
//  Created by mannyadmin on 4/28/19.
//  Copyright © 2019 Stabbity Style Industries. All rights reserved.
//

import Foundation

class FullCharacter {
    var name: String = ""
    var titleId: Int = -1
    var title: String = ""
    var id: Int = -1
    var server: String = ""
    var raceId: Int = -1
    var race: String = ""
    var gender: String = ""
    var cityStateId: Int = -1
    var cityState: String = ""
    var grandCompanyId: Int = -1
    var grandCompany: String = ""
    var rankId = -1
    var rank: String = ""
    
    var jobIdToLevel: [Int: Int] = [:]
    var jobIdToName: [Int: String] = [:]
    var jobIdArray: Array<Int> = []
}
