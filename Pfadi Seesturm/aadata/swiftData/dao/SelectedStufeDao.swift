//
//  SelectedStufenDao.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 22.02.2025.
//
import SwiftData
import Foundation

@Model
final class SelectedStufeDao {
    
    private var stufeRaw: SeesturmStufe.RawValue
    
    init(stufe: SeesturmStufe) {
        self.stufeRaw = stufe.rawValue
    }
    
    func getStufe() throws -> SeesturmStufe {
        guard let validStufe = SeesturmStufe(rawValue: stufeRaw) else {
            throw PfadiSeesturmError.unknownStufe(message: "Stufe \(stufeRaw) unbekannt.")
        }
        return validStufe
    }
    func setStufe(stufe: SeesturmStufe) {
        stufeRaw = stufe.rawValue
    }
    
    static func stufeFilter(stufe: SeesturmStufe) -> Predicate<SelectedStufeDao> {
        return #Predicate<SelectedStufeDao> {
            $0.stufeRaw == stufe.rawValue
        }
    }
}

// set initial value for selected stufen only when the app is downloaded the first time
extension ModelContainer {
    func seedInitialStufenIfNeeded() {
        let key = "hasSeededInitialStufen"
        guard !UserDefaults.standard.bool(forKey: key) else { return }
        let context = ModelContext(self)
        let initialItems: [SelectedStufeDao] = [
            .init(stufe: .biber),
            .init(stufe: .wolf),
            .init(stufe: .pfadi),
            .init(stufe: .pio)
        ]
        initialItems.forEach { context.insert($0) }
        do {
            try context.save()
            UserDefaults.standard.set(true, forKey: key)
        }
        catch {
            // do nothing
        }
    }
}
