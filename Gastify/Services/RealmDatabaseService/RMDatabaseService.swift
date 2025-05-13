import Foundation
import RealmSwift

@MainActor
class RMDatabaseService: DatabaseServiceProtocol {
    
    private let realm = try! Realm()
    
    func fetchRecord(filter: FilterItem) async -> [Record] {
        []
    }

    func saveNewRecord(_ record: Record) async -> Bool {
        do {
            let realmRecord = RMRecord()
            realmRecord.recordId = record.id
            realmRecord.title = record.title
            realmRecord.type = record.type.rawValue
            realmRecord.date = record.date
            realmRecord.amount = record.amount
            
            try realm.write {
                realm.add(realmRecord)
            }
            return true
        } catch {
            return false
        }
    }

    func updateRecord(_ record: Record) async -> Bool {
        true
    }

    func deleteRecord(_ record: Record) async -> Bool {
        true
    }

    func getTotals() async -> (income: Double, outcome: Double) {
        return (0, 0)
    }

    
}
