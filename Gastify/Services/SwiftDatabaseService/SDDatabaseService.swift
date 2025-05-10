    //
    //  SDDatabaseService.swift
    //  Gastify
    //
    //  Created by Julian González on 9/05/25.
    //

import Foundation
import SwiftData

@MainActor //que que las acciones o funciones se ejecuten en el hilo principal
class SDDatabaseService: DatabaseServiceProtocol {
    
    private let container: ModelContainer
    private let context: ModelContext
    
    init() {
        self.container = try! ModelContainer(
            for: SDRecord.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: false)
        )
        self.context = ModelContext(container)
    }
    
    func fetchRecord(filter: FilterItem) async -> [Record] {
        let calendar = Calendar.current
        let now = Date()
        
        let predicate: Predicate<SDRecord>
        
        switch filter {
            case .today:
                let startOfDay = calendar.startOfDay(for: now)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
                
                predicate = #Predicate<SDRecord> { register in
                    register.date >= startOfDay && register.date < endOfDay
                }
                break
            case .week:
                let dateComponents = calendar.dateComponents(
                    [.yearForWeekOfYear, .weekOfYear],
                    from: now
                )
                let startOfWeek = calendar.date(from: dateComponents)!
                let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
                
                predicate = #Predicate<SDRecord> { register in
                    register.date >= startOfWeek && register.date < endOfWeek
                }
                break
            case .month:
                let dateComponents = calendar.dateComponents(
                    [.year, .month],
                    from: now
                )
                let startOfMount = calendar.date(from: dateComponents)!
                let endOfMount = calendar.date(byAdding: .month, value: 1, to: startOfMount)!
                
                predicate = #Predicate<SDRecord> { register in
                    register.date >= startOfMount && register.date < endOfMount
                }
                break
            case .year:
                let onYearAgo = calendar.date(byAdding: .year, value: -1, to: now)!
                
                predicate = #Predicate<SDRecord> { register in
                    register.date >= onYearAgo && register.date <= now
                }
                break
        }
        
        let descriptor = FetchDescriptor<SDRecord>(predicate: predicate)
        
        do {
            let sdRecords = try context.fetch(descriptor)
            return sdRecords.map { $0.toRecord() }
        } catch {
            return []
        }
        
    }
    
    func saveNewRecord(_ record: Record) async -> Bool {
        let sdRecord = SDRecord(
            id: record.id,
            title: record.title,
            date: record.date,
            type: record.type.rawValue,
            amount: record.amount
        )
        
        do {
            context.insert(sdRecord)
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    func updateRecord(_ record: Record) async -> Bool {
        false
    }
    
    func deleteRecord(_ record: Record) async -> Bool {
        false
    }
    
    func getTotals() async -> (income: Double, outCome: Double) {
        return (0, 0)
    }
    
    
}
