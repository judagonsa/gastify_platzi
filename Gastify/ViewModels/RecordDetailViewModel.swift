//
//  RecordDetailViewModel.swift
//  Gastify
//
//  Created by Santiago Moreno on 7/01/25.
//

import Foundation

enum RecordDetaiSheet: Identifiable {
    var id: String { String(describing: self) }
    case updateRecord(_ record: Record)
}

class RecordDetailViewModel: ObservableObject {

    @Published var sheet: RecordDetaiSheet?
    @Published var loading = false
    @Published var showDeleteAlert = false

    let record: Record
    let databaseService: DatabaseServiceProtocol

    init(databaseService: DatabaseServiceProtocol, record: Record) {
        self.databaseService = databaseService
        self.record = record
    }

    func updateRecord() {
        self.sheet = .updateRecord(self.record)
    }

    func deleteRecord(completion: @escaping () -> Void) {
        self.loading = true
        Task {
            if await self.databaseService.deleteRecord(record) {
                await MainActor.run {
                    self.loading = false
                    completion()
                }
            } else {
                print("mostrar error al momento de eliminar un record")
            }
        }
        
        // TODO: Eliminar el registro de la base de datos
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.loading = false
            completion()
        }
    }

    func showDeleteRecordAlert() {
        self.showDeleteAlert = true
    }
}
