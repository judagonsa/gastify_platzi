//
//  MockDatabaseService.swift
//  Gastify
//
//  Created by Julian González on 8/05/25.
//

class MockDatabaseService: DataServiceProtocol {
    
    let mockRecords = MockRecordsHelper.mockRecords()
    
    func fetchRecord(filter: FilterItem) async -> [Record] {
        return MockRecordsHelper.applyFilter(to: mockRecords, by: filter)
    }

    func saveNewRecord(record: Record) async -> Bool {
        return false
    }

    func updateRecord(record: Record) async -> Bool {
        return false
    }

    func deleteRecord(record: Record) async -> Bool {
        return false
    }

    func getTotals() async -> (income: Double, outCome: Double) {
        return (0.0 , 0.0)
    }
}
