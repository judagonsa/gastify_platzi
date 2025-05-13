import Foundation
import RealmSwift

@MainActor
class RMDatabaseService: DatabaseServiceProtocol {
    
    private let realm = try! Realm()
    
    func fetchRecord(filter: FilterItem) async -> [Record] {
        let calendar = Calendar.current
        let now = Date()
        let predicate: NSPredicate
        
        switch filter {
            case .today:
                let startOfDay = calendar.startOfDay(for: now)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                predicate = NSPredicate(
                    format: "date >= %@ AND date < %@",
                    startOfDay as NSDate,
                    endOfDay as NSDate
                )
                
            case .week:
                let startOfWeek = calendar.date(
                    from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
                )!
                let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
                predicate = NSPredicate(
                    format: "date >= %@ AND date < %@",
                    startOfWeek as NSDate,
                    endOfWeek as NSDate
                )
                
            case .month:
                let components = calendar.dateComponents([.year, .month], from: now)
                let startOfMounth = calendar.date(from: components)!
                let endOfMounth = calendar.date(byAdding: .month, value: 1, to: startOfMounth)!
                predicate = NSPredicate(
                    format: "date >= %@ AND date < %@",
                    startOfMounth as NSDate,
                    endOfMounth as NSDate
                )
                
            case .year:
                let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
                predicate = NSPredicate(
                    format: "date >= %@ AND date <= %  @",
                    oneYearAgo as NSDate,
                    now as NSDate
                )
        }
        let results = realm.objects(RMRecord.self).filter(predicate)
        return Array(results).map { $0.toRecord() }
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
        do {
            let results = realm.objects(RMRecord.self).where { query in
                query["recordId"] == record.id
            }
            guard let realmRecord = results.first else {
                return false
            }
            
            try realm.write {
                realmRecord.title = record.title
                realmRecord.amount = record.amount
            }
            
            return true
        } catch {
            return false
        }
    }
    
    func deleteRecord(_ record: Record) async -> Bool {
        do {
            let results = realm.objects(RMRecord.self).where { query in
                query["recordId"] == record.id
            }
            guard let realmRecord = results.first else {
                return false
            }
            
            try realm.write {
                realm.delete(realmRecord)
            }
            
            return true
        } catch {
            return false
        }
    }
    
    func getTotals() async -> (income: Double, outcome: Double) {
        return (0, 0)
    }
    
    
}
