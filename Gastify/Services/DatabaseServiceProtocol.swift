//
//  DataServiceProtocol.swift
//  Gastify
//
//  Created by Julian González on 8/05/25.
//

import Foundation

protocol DatabaseServiceProtocol {
    func fetchRecord(filter: FilterItem) async -> [Record]
    func saveNewRecord(_ record: Record) async -> Bool
    func updateRecord(_ record: Record) async -> Bool
    func deleteRecord(_ record: Record) async -> Bool
    func getTotals() async -> (income: Double, outcome: Double)
}
