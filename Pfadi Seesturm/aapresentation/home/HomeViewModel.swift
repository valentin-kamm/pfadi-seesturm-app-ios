//
//  HomeViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI
import SwiftData

class HomeViewModel: StateManager<HomeListState> {
    
    private let modelContext: ModelContext
    private let calendar: SeesturmCalendar
    private let naechsteAktivitaetService: NaechsteAktivitaetService
    private let aktuellService: AktuellService
    private let anlaesseService: AnlaesseService
    private let weatherService: WeatherService
    init(
        modelContext: ModelContext,
        calendar: SeesturmCalendar,
        naechsteAktivitaetService: NaechsteAktivitaetService,
        aktuellService: AktuellService,
        anlaesseService: AnlaesseService,
        weatherService: WeatherService
    ) {
        self.modelContext = modelContext
        self.calendar = calendar
        self.naechsteAktivitaetService = naechsteAktivitaetService
        self.aktuellService = aktuellService
        self.anlaesseService = anlaesseService
        self.weatherService = weatherService
        super.init(initialState: HomeListState())
    }
    
    var stufenForRefresh: Set<SeesturmStufe> {
        Set(state.naechsteAktivitaetState.keys)
    }
    var stufenDropdownText: String {
        switch state.selectedStufen {
        case .success(let stufen):
            if stufen.count == 0 {
                "Wählen"
            }
            else if stufen.count == 1 {
                stufen.first?.stufenName ?? "Wählen"
            }
            else if stufen.count == 4 {
                "Alle"
            }
            else {
                "Mehrere"
            }
        default:
            "Stufe"
        }
    }
    var addRemoveStufenStateBinding: Binding<ActionState<SeesturmStufe>> {
        Binding(
            get: { self.state.addRemoveStufenState },
            set: { newValue in
                self.updateState { state in
                    state.addRemoveStufenState = newValue
                }
            }
        )
    }
    
    func isStufeSelected(stufe: SeesturmStufe) -> Bool {
        switch state.selectedStufen {
        case .success(let stufen):
            return stufen.contains(stufe)
        default:
            return false
        }
    }
    
    func loadInitialData() async {
        
        var tasks: [() async -> Void] = []
        
        tasks.append {
            await self.loadInitialSelectedStufenAndFetchNecessaryAktivitaeten()
        }
        if state.aktuellState.taskShouldRun {
            tasks.append {
                await self.fetchLatestPost(isPullToRefresh: false)
            }
        }
        if state.anlaesseState.taskShouldRun {
            tasks.append {
                await self.fetchNext3Events(isPullToRefresh: false)
            }
        }
        if state.weatherState.taskShouldRun {
            tasks.append {
                await self.fetchForecast(isPullToRefresh: false)
            }
        }
        await withTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.addTask {
                    await task()
                }
            }
        }
    }
    
    func refresh() async {
        
        var tasks: [() async -> Void] = []
        
        tasks.append {
            await self.fetchAktivitaeten(stufen: self.stufenForRefresh, isPullToRefresh: true)
        }
        tasks.append {
            await self.fetchLatestPost(isPullToRefresh: true)
        }
        tasks.append {
            await self.fetchNext3Events(isPullToRefresh: true)
        }
        tasks.append {
            await self.fetchForecast(isPullToRefresh: true)
        }
        await withTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.addTask {
                    await task()
                }
            }
        }
    }
    
    private func loadInitialSelectedStufenAndFetchNecessaryAktivitaeten() async {
        let result = naechsteAktivitaetService.readSelectedStufen(modelContext: modelContext)
        switch result {
        case .error(let e):
            updateState { state in
                state.selectedStufen = .error(message: "Nächste Aktivitäten konnten nicht geladen werden. \(e.defaultMessage)")
            }
        case .success(let d):
            updateState { state in
                state.selectedStufen = .success(data: d)
            }
            await fetchNecessaryAktivitaeten(stufen: d, isPullToRefresh: false)
        }
    }
    private func fetchNecessaryAktivitaeten(stufen: Set<SeesturmStufe>, isPullToRefresh: Bool) async {
        let stufenToLoad = stufen.filter { !state.naechsteAktivitaetState.keys.contains($0) }
        var tasks: [() async -> Void] = []
        for stufe in stufenToLoad {
            if let stufenState = state.naechsteAktivitaetState[stufe] {
                if stufenState.taskShouldRun {
                    tasks.append {
                        await self.fetchAktivitaet(stufe: stufe, isPullToRefresh: isPullToRefresh)
                    }
                }
            }
            else {
                tasks.append {
                    await self.fetchAktivitaet(stufe: stufe, isPullToRefresh: isPullToRefresh)
                }
            }
        }
        await withTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.addTask {
                    await task()
                }
            }
        }
    }
    private func fetchAktivitaeten(stufen: Set<SeesturmStufe>, isPullToRefresh: Bool) async {
        var tasks: [() async -> Void] = []
        for stufe in stufen {
            tasks.append {
                await self.fetchAktivitaet(stufe: stufe, isPullToRefresh: isPullToRefresh)
            }
        }
        await withTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.addTask {
                    await task()
                }
            }
        }
    }
    func fetchAktivitaet(stufe: SeesturmStufe, isPullToRefresh: Bool) async {
        if !isPullToRefresh {
            upsertNaechsteAktivitaetState(stufe: stufe, newState: .loading(subState: .loading))
        }
        let result = await naechsteAktivitaetService.fetchNaechsteAktivitaet(stufe: stufe)
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                upsertNaechsteAktivitaetState(stufe: stufe, newState: .loading(subState: .retry))
            default:
                upsertNaechsteAktivitaetState(stufe: stufe, newState: .error(message: "Nächste Aktivität der \(stufe.stufenName) konnte nicht geladen werden. \(e.defaultMessage)"))
            }
        case .success(let d):
            upsertNaechsteAktivitaetState(stufe: stufe, newState: .success(data: d))
        }
    }
    private func upsertNaechsteAktivitaetState(stufe: SeesturmStufe, newState: UiState<GoogleCalendarEvent?>) {
        updateState { state in
            state.naechsteAktivitaetState[stufe] = newState
        }
    }
    
    func toggleStufe(stufe: SeesturmStufe) {
        switch state.selectedStufen {
        case .success(let stufen):
            if stufen.contains(stufe) {
                removeStufe(stufe: stufe)
            }
            else {
                addStufe(stufe: stufe)
            }
        default:
            return
        }
    }
    private func addStufe(stufe: SeesturmStufe) {
        let result = naechsteAktivitaetService.addStufe(stufe: stufe, modelContext: modelContext)
        switch result {
        case .error(let e):
            updateState { state in
                state.addRemoveStufenState = .error(action: stufe, message: "\(stufe.stufenName) konnte nicht hinzugefügt werden. \(e.defaultMessage)")
            }
        case .success(let d):
            updateState { state in
                state.selectedStufen = .success(data: d)
            }
            Task {
                await fetchNecessaryAktivitaeten(stufen: d, isPullToRefresh: false)
            }
        }
    }
    private func removeStufe(stufe: SeesturmStufe) {
        let result = naechsteAktivitaetService.deleteStufe(stufe: stufe, modelContext: modelContext)
        switch result {
        case .error(let e):
            updateState { state in
                state.addRemoveStufenState = .error(action: stufe, message: "\(stufe.stufenName) konnte nicht entfernt werden. \(e.defaultMessage)")
            }
        case .success(let d):
            updateState { state in
                state.selectedStufen = .success(data: d)
            }
            Task {
                await fetchNecessaryAktivitaeten(stufen: d, isPullToRefresh: false)
            }
        }
    }
    
    func fetchForecast(isPullToRefresh: Bool) async {
        
        if !isPullToRefresh {
            updateState { state in
                state.weatherState = .loading(subState: .loading)
            }
        }
        let result = await weatherService.getWeather()
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                updateState { state in
                    state.weatherState = .loading(subState: .retry)
                }
            default:
                updateState { state in
                    state.weatherState = .error(message: "Das Wetter vom nächsten Samstag konnte nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            updateState { state in
                state.weatherState = .success(data: d)
            }
        }
    }
    
    func fetchLatestPost(isPullToRefresh: Bool) async {
        
        if !isPullToRefresh {
            updateState { state in
                state.aktuellState = .loading(subState: .loading)
            }
        }
        let result = await aktuellService.fetchLatestPost()
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                updateState { state in
                    state.aktuellState = .loading(subState: .retry)
                }
            default:
                updateState { state in
                    state.aktuellState = .error(message: "Der neuste Post konnte nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            updateState { state in
                state.aktuellState = .success(data: d)
            }
        }
    }
    
    func fetchNext3Events(isPullToRefresh: Bool) async {
        
        if !isPullToRefresh {
            updateState { state in
                state.anlaesseState = .loading(subState: .loading)
            }
        }
        let result = await anlaesseService.getNext3Events(calendar: calendar)
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                updateState { state in
                    state.anlaesseState = .loading(subState: .retry)
                }
            default:
                updateState { state in
                    state.anlaesseState = .error(message: "Die nächsten Anlässe konnten nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            updateState { state in
                state.anlaesseState = .success(data: d.items)
            }
        }
    }
}
