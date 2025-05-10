//
//  SDRecord.swift
//  Gastify
//
//  Created by Julian González on 9/05/25.
//


import Foundation
import SwiftData

@Model
class SDRecord {
    var id: String
    var recordId: String
    var title: String
    var date: Date
    var type: String
    var amount: Double
    
    init(id: String, title: String, date: Date, type: String, amount: Double) {
        self.id = id
        self.recordId = id
        self.title = title
        self.date = date
        self.type = type
        self.amount = amount
    }
}

extension SDRecord: ToRecordProtocol {
    func toRecord() -> Record {
        Record(
            id: id,
            title: title,
            date: date,
            type: RcordType(rawValue: type) ?? .income,
            amount: amount
        )
    }
}
