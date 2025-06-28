//
//  HomeViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//
import SwiftUI
import Observation

@Observable
@MainActor
class HomeViewModel {
    
    var addRemoveStufenState: ActionState<SeesturmStufe> = .idle
    var naechsteAktivitaetState: [SeesturmStufe: UiState<GoogleCalendarEvent?>] = [:]
    var selectedStufenState: UiState<Set<SeesturmStufe>> = .loading(subState: .idle)
    var aktuellState: UiState<WordpressPost> = .loading(subState: .idle)
    var anlaesseState: UiState<[GoogleCalendarEvent]> = .loading(subState: .idle)
    var weatherState: UiState<Weather> = .loading(subState: .idle)
    
    private let calendar: SeesturmCalendar
    private let naechsteAktivitaetService: NaechsteAktivitaetService
    private let aktuellService: AktuellService
    private let anlaesseService: AnlaesseService
    private let weatherService: WeatherService
    
    init(
        calendar: SeesturmCalendar,
        naechsteAktivitaetService: NaechsteAktivitaetService,
        aktuellService: AktuellService,
        anlaesseService: AnlaesseService,
        weatherService: WeatherService
    ) {
        self.calendar = calendar
        self.naechsteAktivitaetService = naechsteAktivitaetService
        self.aktuellService = aktuellService
        self.anlaesseService = anlaesseService
        self.weatherService = weatherService
    }
    
    private var stufenForRefresh: Set<SeesturmStufe> {
        Set(naechsteAktivitaetState.keys)
    }
    
    func loadInitialData() async {
        
        var tasks: [() async -> Void] = []
        
        tasks.append {
            await self.loadInitialSelectedStufenAndFetchNecessaryAktivitaeten()
        }
        if aktuellState.taskShouldRun {
            tasks.append {
                await self.fetchLatestPost(isPullToRefresh: false)
            }
        }
        if anlaesseState.taskShouldRun {
            tasks.append {
                await self.fetchNext3Events(isPullToRefresh: false)
            }
        }
        if weatherState.taskShouldRun {
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
            await self.fetchAktivitaeten(for: self.stufenForRefresh, isPullToRefresh: true)
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
        
        let result = naechsteAktivitaetService.readSelectedStufen()
        
        switch result {
        case .error(let e):
            selectedStufenState = .error(message: "Nächste Aktivitäten konnten nicht geladen werden. \(e.defaultMessage)")
        case .success(let d):
            selectedStufenState = .success(data: d)
            await fetchNecessaryAktivitaeten(for: d, isPullToRefresh: false)
        }
    }
    
    private func fetchNecessaryAktivitaeten(for stufen: Set<SeesturmStufe>, isPullToRefresh: Bool) async {
        
        let stufenToLoad = stufen.filter { !naechsteAktivitaetState.keys.contains($0) }
        
        var tasks: [() async -> Void] = []
        
        for stufe in stufenToLoad {
            if let stufenState = naechsteAktivitaetState[stufe] {
                if stufenState.taskShouldRun {
                    tasks.append {
                        await self.fetchAktivitaet(for: stufe, isPullToRefresh: isPullToRefresh)
                    }
                }
            }
            else {
                tasks.append {
                    await self.fetchAktivitaet(for: stufe, isPullToRefresh: isPullToRefresh)
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
    
    private func fetchAktivitaeten(for stufen: Set<SeesturmStufe>, isPullToRefresh: Bool) async {
        
        var tasks: [() async -> Void] = []
        
        for stufe in stufen {
            tasks.append {
                await self.fetchAktivitaet(for: stufe, isPullToRefresh: isPullToRefresh)
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
    
    func fetchAktivitaet(for stufe: SeesturmStufe, isPullToRefresh: Bool) async {
        
        if !isPullToRefresh {
            upsertNaechsteAktivitaetState(for: stufe, newState: .loading(subState: .loading))
        }
        
        let result = await naechsteAktivitaetService.fetchNaechsteAktivitaet(for: stufe)
        
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                upsertNaechsteAktivitaetState(for: stufe, newState: .loading(subState: .retry))
            default:
                upsertNaechsteAktivitaetState(for: stufe, newState: .error(message: "Nächste Aktivität der \(stufe.name) konnte nicht geladen werden. \(e.defaultMessage)"))
            }
        case .success(let d):
            upsertNaechsteAktivitaetState(for: stufe, newState: .success(data: d))
        }
    }
    
    private func upsertNaechsteAktivitaetState(for stufe: SeesturmStufe, newState: UiState<GoogleCalendarEvent?>) {
        if naechsteAktivitaetState.isEmpty {
            // no animation if nothing is displayed yet -> looks bad
            naechsteAktivitaetState[stufe] = newState
        }
        else {
            withAnimation {
                naechsteAktivitaetState[stufe] = newState
            }
        }
    }
    
    func toggleStufe(stufe: SeesturmStufe) {
        
        if case .success(let stufen) = selectedStufenState {
            if stufen.contains(stufe) {
                removeStufe(stufe: stufe)
            }
            else {
                addStufe(stufe: stufe)
            }
        }
    }
    
    private func addStufe(stufe: SeesturmStufe) {
        
        let result = naechsteAktivitaetService.addStufe(stufe: stufe)
        
        switch result {
        case .error(let e):
            withAnimation {
                addRemoveStufenState = .error(action: stufe, message: "\(stufe.name) konnte nicht hinzugefügt werden. \(e.defaultMessage)")
            }
        case .success(let stufen):
            withAnimation {
                selectedStufenState = .success(data: stufen)
            }
            Task {
                await fetchNecessaryAktivitaeten(for: stufen, isPullToRefresh: false)
            }
        }
    }
    
    private func removeStufe(stufe: SeesturmStufe) {
        
        let result = naechsteAktivitaetService.deleteStufe(stufe: stufe)
        
        switch result {
        case .error(let e):
            withAnimation {
                addRemoveStufenState = .error(action: stufe, message: "\(stufe.name) konnte nicht entfernt werden. \(e.defaultMessage)")
            }
        case .success(let stufen):
            withAnimation {
                selectedStufenState = .success(data: stufen)
            }
            Task {
                await fetchNecessaryAktivitaeten(for: stufen, isPullToRefresh: false)
            }
        }
    }
    
    func fetchForecast(isPullToRefresh: Bool) async {
        
        if !isPullToRefresh {
            withAnimation {
                weatherState = .loading(subState: .loading)
            }
        }
        
        let result = await weatherService.getWeather()
        
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                withAnimation {
                    weatherState = .loading(subState: .retry)
                }
            default:
                withAnimation {
                    weatherState = .error(message: "Das Wetter vom nächsten Samstag konnte nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            withAnimation {
                weatherState = .success(data: d)
            }
        }
    }
    
    func fetchLatestPost(isPullToRefresh: Bool) async {
        
        if !isPullToRefresh {
            withAnimation {
                aktuellState = .loading(subState: .loading)
            }
        }
        
        let result = await aktuellService.fetchLatestPost()
        
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                withAnimation {
                    aktuellState = .loading(subState: .retry)
                }
            default:
                withAnimation {
                    aktuellState = .error(message: "Der neuste Post konnte nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            withAnimation {
                aktuellState = .success(data: d)
            }
        }
    }
    
    func fetchNext3Events(isPullToRefresh: Bool) async {
        
        if !isPullToRefresh {
            withAnimation {
                anlaesseState = .loading(subState: .loading)
            }
        }
        
        let result = await anlaesseService.fetchNextThreeEvents(calendar: calendar)
        
        switch result {
        case .error(let e):
            switch e {
            case .cancelled:
                withAnimation {
                    anlaesseState = .loading(subState: .retry)
                }
            default:
                withAnimation {
                    anlaesseState = .error(message: "Die nächsten Anlässe konnten nicht geladen werden. \(e.defaultMessage)")
                }
            }
        case .success(let d):
            withAnimation {
                anlaesseState = .success(data: d.items)
            }
        }
    }
}
