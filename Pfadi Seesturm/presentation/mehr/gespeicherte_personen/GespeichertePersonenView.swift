//
//  GespeichertePersonenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI
import SwiftData

struct GespeichertePersonenView: View {
        
    @Environment(\.modelContext) var modelContext: ModelContext
    @Query private var personenQuery: [GespeichertePersonDao]
    private var personen: [GespeichertePerson] {
        withAnimation {
            personenQuery.map { $0.toGespeichertePerson() }
        }
    }
    
    @State private var showInsertSheet = false
    @State private var deletingError: String? = nil
    
    private var showSnackbar: Binding<Bool> {
        Binding(
            get: { deletingError != nil },
            set: { isShown in
                if !isShown {
                    withAnimation {
                        deletingError = nil
                    }
                }
            }
        )
    }
    
    var body: some View {
        GespeichertePersonenContentView(
            personen: personen,
            onDelete: { indexSet in
                do {
                    for index in indexSet {
                        modelContext.delete(personenQuery[index])
                        try modelContext.save()
                    }
                }
                catch {
                    withAnimation {
                        deletingError = "Eine Person konnte nicht gelöscht werden. Versuche es erneut."
                    }
                }
            },
            onShowSheet: {
                showInsertSheet = true
            }
        )
        .sheet(isPresented: $showInsertSheet) {
            GespeichertePersonHinzufuegenView()
        }
        .customSnackbar(
            show: showSnackbar,
            type: .error,
            message: deletingError ?? "Eine Person konnte nicht gelöscht werden. Unbekannter Fehler.",
            dismissAutomatically: true,
            allowManualDismiss: true
        )
    }
}

private struct GespeichertePersonenContentView: View {
    
    private let personen: [GespeichertePerson]
    private let onDelete: (IndexSet) -> Void
    private let onShowSheet: () -> Void
    
    init(
        personen: [GespeichertePerson],
        onDelete: @escaping (IndexSet) -> Void,
        onShowSheet: @escaping () -> Void
    ) {
        self.personen = personen
        self.onDelete = onDelete
        self.onShowSheet = onShowSheet
    }
    
    var body: some View {
        List {
            Section {
                ForEach(Array(personen.enumerated()), id: \.element.id) { index, person in
                    Text(person.displayName)
                }
                .onDelete { indexSet in
                    onDelete(indexSet)
                }
            } header: {
                Text("Gespeicherte Personen")
            }
        }
        .background(Color.customBackground)
        .toolbar {
            if !personen.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: onShowSheet) {
                    Image(systemName: "plus")
                }
            }
        }
        .scrollDisabled(personen.isEmpty)
        .overlay {
            if personen.isEmpty {
                ContentUnavailableView(
                    label: {
                        Label("Keine Personen gespeichert", systemImage: "person.slash")
                    },
                    description: {
                        Text("Füge die Angaben von Personen hinzu, die du of von Aktivitäten abmeldest. So musst du sie nicht jedes Mal neu eintragen.")
                    },
                    actions: {
                        SeesturmButton(
                            type: .primary,
                            action: .sync(action: onShowSheet),
                            title: "Person hinzufügen",
                            icon: .system(name: "person.badge.plus")
                        )
                    }
                )
                .background(Material.thick)
            }
        }
    }
}

#Preview("Empty") {
    NavigationStack(path: .constant(NavigationPath())) {
        GespeichertePersonenContentView(
            personen: [],
            onDelete: { _ in },
            onShowSheet: {}
        )
    }
}
#Preview("Success") {
    NavigationStack(path: .constant(NavigationPath())) {
        GespeichertePersonenContentView(
            personen: [
                DummyData.gespeichertePerson1,
                DummyData.gespeichertePerson2,
                DummyData.gespeichertePerson3
            ],
            onDelete: { _ in },
            onShowSheet: {}
        )
    }
}
