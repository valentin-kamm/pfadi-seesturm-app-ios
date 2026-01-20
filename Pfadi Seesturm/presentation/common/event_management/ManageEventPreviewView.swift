//
//  ManageEventPreviewView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.01.2026.
//
import SwiftUI

struct ManageEventPreviewView: View {
    
    @Environment(\.wordpressModule) private var wordpressModule: WordpressModule
    private let type: EventPreviewType
    private let event: GoogleCalendarEvent
    
    init(
        type: EventPreviewType,
        event: GoogleCalendarEvent
    ) {
        self.type = type
        self.event = event
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch type {
                case .aktivitaet(let stufe):
                    ManageAktivitaetenPreviewView(stufen: Set([stufe]), event: event)
                case .multipleAktivitaeten(let stufen):
                    ManageAktivitaetenPreviewView(stufen: stufen, event: event)
                case .termin(let calendar):
                    ManageTerminPreviewView(calendar: calendar, event: event)
                }
            }
            .navigationTitle(type.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: ManageEventPreviewViewNavigationDestination.self) { destination in
                switch destination {
                case .anlassDetail(let calendar):
                    TermineDetailView(
                        viewModel: TermineDetailViewModel(
                            service: wordpressModule.anlaesseService,
                            input: .object(object: event),
                            calendar: calendar
                        ),
                        calendar: calendar
                    )
                }
            }
        }
    }
}

private struct ManageAktivitaetenPreviewView: View {
    
    @State private var selectedStufe: SeesturmStufe
    private let stufen: Set<SeesturmStufe>
    private let event: GoogleCalendarEvent
    
    init(
        stufen: Set<SeesturmStufe>,
        event: GoogleCalendarEvent
    ) {
        precondition(!stufen.isEmpty, "Stufen must not be empty")
        self.stufen = stufen
        self.event = event
        self._selectedStufe = State(initialValue: Array(stufen).sorted { $0.id < $1.id }.first!)
    }
    
    var body: some View {
        ScrollView {
            AktivitaetDetailCardView(
                stufe: selectedStufe,
                aktivitaet: event,
                openSheet: { _ in },
                buttonsDisabled: true
            )
            .id(selectedStufe)
        }
        .safeAreaInset(edge: .top) {
            if stufen.count > 1 {
                Picker(
                    "Stufe",
                    selection: Binding(
                        get: {
                            selectedStufe
                        },
                        set: { stufe in
                            withAnimation {
                                selectedStufe = stufe
                            }
                        }
                    )
                ) {
                    ForEach(Array(stufen).sorted { $0.id < $1.id }, id: \.self) { stufe in
                        Text(stufe.name)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
            }
        }
    }
}

private struct ManageTerminPreviewView: View {
    
    private let calendar: SeesturmCalendar
    private let event: GoogleCalendarEvent
    
    init(
        calendar: SeesturmCalendar,
        event: GoogleCalendarEvent
    ) {
        self.calendar = calendar
        self.event = event
    }
    
    var body: some View {
        ScrollView {
            NavigationLink(value: ManageEventPreviewViewNavigationDestination.anlassDetail(calendar: calendar)) {
                AnlassCardView(
                    event: event,
                    calendar: calendar
                )
            }
            .padding(.top)
            .foregroundStyle(Color.primary)
        }
    }
}

enum EventPreviewType {
    
    case aktivitaet(stufe: SeesturmStufe)
    case multipleAktivitaeten(stufen: Set<SeesturmStufe>)
    case termin(calendar: SeesturmCalendar)
    
    var navigationTitle: String {
        switch self {
        case .aktivitaet(let stufe):
            "Vorschau \(stufe.aktivitaetDescription)"
        case .multipleAktivitaeten(_):
            "Vorschau Aktivitäten"
        case .termin(_):
            "Vorschau Anlass"
        }
    }
}

private enum ManageEventPreviewViewNavigationDestination: Hashable {
    case anlassDetail(calendar: SeesturmCalendar)
}

#Preview("Termin normal") {
    ManageEventPreviewView(
        type: .termin(calendar: .termine),
        event: DummyData.aktivitaet2
    )
}

#Preview("Termin Leitungsteam") {
    ManageEventPreviewView(
        type: .termin(calendar: .termineLeitungsteam),
        event: DummyData.aktivitaet1
    )
}

#Preview("Single aktivität") {
    ManageEventPreviewView(
        type: .aktivitaet(stufe: .wolf),
        event: DummyData.aktivitaet1
    )
}

#Preview("Multiple aktivitäten") {
    ManageEventPreviewView(
        type: .multipleAktivitaeten(stufen: Set(SeesturmStufe.allCases)),
        event: DummyData.aktivitaet1
    )
}
