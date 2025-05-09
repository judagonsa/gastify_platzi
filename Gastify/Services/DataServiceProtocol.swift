//
//  DataServiceProtocol.swift
//  Gastify
//
//  Created by Julian González on 8/05/25.
//

import Foundation

protocol DataServiceProtocol {
    func fetchRecord(filter: FilterItem) async -> [Record]
    func saveNewRecord(record: Record) async -> Bool
    func updateRecord(record: Record) async -> Bool
    func deleteRecord(record: Record) async -> Bool
    func getTotals() async -> (income: Double, outCome: Double)
}
