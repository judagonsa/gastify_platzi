//
//  MockDatabaseService.swift
//  Gastify
//
//  Created by Julian González on 8/05/25.
//

class MockDatabaseService: DatabaseServiceProtocol {
    
    let mockRecords = MockRecordsHelper.mockRecords()
    
    func fetchRecord(filter: FilterItem) async -> [Record] {
        return MockRecordsHelper.applyFilter(to: mockRecords, by: filter)
    }

    func saveNewRecord(_ record: Record) async -> Bool {
        return false
    }

    func updateRecord(_ record: Record) async -> Bool {
        return true
    }

    func deleteRecord(_ record: Record) async -> Bool {
        return true
    }

    func getTotals() async -> (income: Double, outCome: Double) {
        return (0.0 , 0.0)
    }
}
