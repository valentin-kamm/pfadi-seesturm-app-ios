//
//  GespeichertePersonHinzufügenView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 10.11.2024.
//

import SwiftUI
import SwiftData

struct GespeichertePersonHinzufuegenView: View {
        
    @Environment(\.modelContext) private var modelContext: ModelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var vorname = ""
    @State private var nachname = ""
    @State private var pfadiname = ""
    @State private var savingError: String? = nil
    
    @Binding private var insertPersonState: ActionState<Void>
    
    init(
        insertPersonState: Binding<ActionState<Void>>
    ) {
        self._insertPersonState = insertPersonState
    }
    
    private var newPerson: GespeichertePerson {
        GespeichertePerson(
            id: UUID(),
            vorname: vorname.trimmingCharacters(in: .whitespacesAndNewlines),
            nachname: nachname.trimmingCharacters(in: .whitespacesAndNewlines),
            pfadiname: pfadiname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : pfadiname.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
    private var isNewPersonOk: Bool {
        if newPerson.vorname.isEmpty || newPerson.nachname.isEmpty {
            return false
        }
        return true
    }
    private var showSnackbar: Binding<Bool> {
        Binding(
            get: { savingError != nil },
            set: { isShown in
                if !isShown {
                    withAnimation {
                        savingError = nil
                    }
                }
            }
        )
    }
    
    private enum GespeichertePersonenFields: String, FocusControlItem {
        case vorname
        case nachname
        case pfadiname
        var id: GespeichertePersonenFields { self }
    }
    
    var body: some View {
        NavigationStack {
            FocusControlView(allFields: GespeichertePersonenFields.allCases) { focused in
                Form {
                    Section(footer: Text("Speichere die Angaben einer Person, die du häufig von Aktivitäten abmeldest.")) {
                        HStack {
                            Image(systemName: "person.text.rectangle")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            TextField("Vorname", text: $vorname)
                                .focused(focused, equals: .vorname)
                                .submitLabel(.next)
                                .onSubmit {
                                    focused.wrappedValue = .nachname
                                }
                        }
                        HStack {
                            Image(systemName: "person.text.rectangle.fill")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            TextField("Nachname", text: $nachname)
                                .focused(focused, equals: .nachname)
                                .submitLabel(.next)
                                .onSubmit {
                                    focused.wrappedValue = .pfadiname
                                }
                        }
                        HStack {
                            Image(systemName: "face.smiling")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            TextField("Pfadiname (optional)", text: $pfadiname)
                                .focused(focused, equals: .pfadiname)
                                .submitLabel(.done)
                                .onSubmit {
                                    focused.wrappedValue = nil
                                }
                        }
                    }
                    Section {
                        SeesturmButton(
                            type: .primary,
                            action: .sync(action: { addPerson() }),
                            title: "Speichern"
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .navigationTitle("Person hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .customSnackbar(
                show: showSnackbar,
                type: .error,
                message: savingError ?? "Die Person konnte nicht gespeichert werden. Unbekannter Fehler.",
                dismissAutomatically: true,
                allowManualDismiss: true
            )
        }
    }
    
    private func addPerson() {
        if !isNewPersonOk {
            withAnimation {
                savingError = "Die Person kann nicht gespeichert werden. Die Daten sind unvollständig."
            }
            return
        }
        do {
            modelContext.insert(newPerson.toGespeichertePersonDao())
            try modelContext.save()
            insertPersonState = .success(action: (), message: "Person erfolgreich gespeichert")
            dismiss()
        }
        catch {
            withAnimation {
                savingError = "Die Person kann nicht gespeichert werden. Versuche es erneut."
            }
        }
    }
}

#Preview {
    GespeichertePersonHinzufuegenView(
        insertPersonState: .constant(.idle)
    )
}
