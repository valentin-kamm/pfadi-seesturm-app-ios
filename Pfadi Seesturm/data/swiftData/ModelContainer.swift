//
//  ModelContainer.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 29.05.2025.
//
import SwiftData

let seesturmModelContainer: ModelContainer = {
    let schema = Schema([SelectedStufeDao.self, GespeichertePersonDao.self, SubscribedFCMNotificationTopicDao.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: false)
    do {
        let container = try ModelContainer(for: schema, configurations: [config])
        container.seedInitialStufenIfNeeded()
        return container
    }
    catch {
        fatalError("Failed to create ModelContainer: \(error)")
    }
}()
