//
//  HomeViewModel.swift
//  Gastify
//
//  Created by Santiago Moreno on 5/01/25.
//

import Foundation

enum HomeSheet: Identifiable {
    var id: Self { self }
    case newRecord
}

enum HomeNavigationRoute: Hashable {
    case recordDetail(_ record: Record)
}

class HomeViewModel: ObservableObject {

    @Published var path = [HomeNavigationRoute]()
    @Published var sheet: HomeSheet?
    @Published var loading = false
    @Published var loadingTotals = false

    var activeFilter: FilterItem = .today
    var records: [Record] = []
    var totalIncome: Double = 0
    var totalOutcome: Double = 0
    let filters: [FilterItem] = [.today, .week, .month, .year]
    
    let databaseService: DatabaseServiceProtocol
    
    init(databaseService: DatabaseServiceProtocol) {
        self.databaseService = databaseService
    }

    var totalIncomeText: String {
        return "$\(self.totalIncome.toMoneyAmount())"
    }

    var totalOutcomeText: String {
        return "$\(self.totalOutcome.toMoneyAmount())"
    }

    func getInitialData() {
        self.getTotals()
        self.getRecords()
    }

    func getTotals() {
        // TODO: - Cambiar esta logica para obtener la data desde un servicio de BD
        self.loadingTotals = true
        Task {
            let total = await self.databaseService.getTotals()
            self.totalIncome = total.income
            self.totalOutcome = total.outcome
            
            await MainActor.run {
                self.loadingTotals = false
            }
        }
    }

    func getRecords() {
        // TODO: - Cambiar esta logica para obtener la data desde un servicio de BD
        self.loading = true
        Task {
            self.records = await self.databaseService.fetchRecord(filter: self.activeFilter)
            
            await MainActor.run {
                self.loading = false
            }
        }
    }

    func filterSelected(_ filter: FilterItem) {
        self.activeFilter = filter
        self.getRecords()
    }

    func isFilterSelected(_ filter: FilterItem) -> Bool {
        self.activeFilter == filter
    }

    func reorganizeFilters() -> [FilterItem] {
        guard let index = filters.firstIndex(of: activeFilter),
              index != 0 else { return filters }
        var newFilters = filters
        let selectedFilter = newFilters.remove(at: index)
        newFilters.insert(selectedFilter, at: 0)
        return newFilters
    }

    func newRecord() {
        self.sheet = .newRecord
    }

    func goToDetail(_ record: Record) {
        self.path.append(.recordDetail(record))
    }
}
