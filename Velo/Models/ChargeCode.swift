//
//  ChargeCode.swift
//  Velo
//
//  Created by Nick Black on 6/14/25.
//

import Foundation

struct ChargeCode: Persistable {
    var id: Int
    var name: String
    
    static var path: String = "/time/chargeCodes"
}
