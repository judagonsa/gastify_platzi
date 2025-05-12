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
        
        let id = record.id
        let predicate = #Predicate<SDRecord> { $0.recordId == id }
        let descriptor = FetchDescriptor<SDRecord>(predicate: predicate)
        
        do {
            guard let existingRecord = try context.fetch(descriptor).first else { return false }
            existingRecord.title = record.title
            existingRecord.amount = record.amount
            
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    func deleteRecord(_ record: Record) async -> Bool {
        let id = record.id
        let predicate = #Predicate<SDRecord> { $0.recordId == id }
        let descriptor = FetchDescriptor<SDRecord>(predicate: predicate)
        
        do {
            guard let existingRecord = try context.fetch(descriptor).first else { return false }
            
            context.delete(existingRecord)
            
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    func getTotals() async -> (income: Double, outcome: Double) {
        do {
            let incomePredicate = #Predicate<SDRecord> { $0.type == "INCOME" }
            let outcomePredicate = #Predicate<SDRecord> { $0.type == "OUTCOME" }
            
            let incomeDescriptor = FetchDescriptor<SDRecord>(predicate: incomePredicate)
            let outcomeDescriptor = FetchDescriptor<SDRecord>(predicate: outcomePredicate)
            
            let incomeRecords = try context.fetch(incomeDescriptor)
            let outcomeRecords = try context.fetch(outcomeDescriptor)
            
            let income = incomeRecords.reduce(0.0) { $0 + $1.amount }
            let outcome = outcomeRecords.reduce(0.0) { $0 + $1.amount }
            
            return (income: income, outcome: outcome)
        } catch {
            return (income: 0.0, outcome: 0.0)
        }
    }
}
