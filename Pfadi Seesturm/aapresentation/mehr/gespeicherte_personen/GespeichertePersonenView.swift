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
        personenQuery.map { $0.toGespeichertePerson() }
    }
    
    @State private var showInsertSheet = false
    @State private var deletingError: String? = nil
    
    // computed properties
    private var showSnackbar: Binding<Bool> {
        Binding(
            get: { deletingError != nil },
            set: { _ in
                withAnimation {
                    deletingError = nil
                }
            }
        )
    }
    
    var body: some View {
        List {
            Section {
                ForEach(Array(personen.enumerated()), id: \.element.id) { index, person in
                    Text(person.displayName)
                }
                .onDelete { indexSet in
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
                }
            } header: {
                Text("Gespeicherte Personen")
            }
        }
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
                            style: .primary,
                            action: .sync(action: {
                                showInsertSheet = true
                            }),
                            title: "Person hinzufügen",
                            icon: .system(name: "person.badge.plus")
                        )
                    }
                )
                .background(Color.customBackground)
            }
        }
        .background(Color.customBackground)
        .sheet(isPresented: $showInsertSheet) {
            GespeichertePersonHinzufuegenView()
        }
        .toolbar {
            if !personen.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showInsertSheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .scrollDisabled(personen.isEmpty)
        .customSnackbar(
            show: showSnackbar,
            type: .error,
            message: deletingError ?? "Eine Person konnte nicht gelöscht werden. Unbekannter Fehler.",
            dismissAutomatically: true,
            allowManualDismiss: true
        )
    }
}

#Preview {
    GespeichertePersonenView()
}
