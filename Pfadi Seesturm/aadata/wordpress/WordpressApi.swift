//
//  WordpressApi.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 26.01.2025.
//
import Foundation

protocol WordpressApi {
    
    var baseUrl: String { get }
    
    func getPosts(start: Int, length: Int) async throws -> WordpressPostsDto
    func getPost(postId: Int) async throws -> WordpressPostDto
    
    func getEvents(calendarId: String, includePast: Bool, maxResults: Int) async throws -> GoogleCalendarEventsDto
    func getEvents(calendarId: String, pageToken: String, maxResults: Int) async throws -> GoogleCalendarEventsDto
    func getEvents(calendarId: String, timeMin: Date) async throws -> GoogleCalendarEventsDto
    func getEvent(calendarId: String, eventId: String) async throws -> GoogleCalendarEventDto
    
    func getWeather() async throws -> WeatherDto
    
    func getPhotosPfadijahre() async throws -> [WordpressPhotoGalleryDto]
    func getPhotosAlbums(id: String) async throws -> [WordpressPhotoGalleryDto]
    func getPhotos(id: String) async throws -> [WordpressPhotoDto]
    
    func getDocuments() async throws -> [WordpressDocumentDto]
    func getLuuchtturm() async throws -> [WordpressDocumentDto]
    
    func getLeitungsteam() async throws -> [LeitungsteamDto]
}

class WordpressApiImpl: WordpressApi {
    
    var baseUrl: String
    init(baseUrl: String) {
        self.baseUrl = baseUrl
    }
    
    func getPosts(start: Int, length: Int) async throws -> WordpressPostsDto {
        let urlString = "\(baseUrl)aktuell/posts?start=" + String(start) + "&length=" + String(length)
        return try await HttpUtil.shared.performGetRequest(urlString: urlString, keyDecodingStrategy: .convertFromSnakeCase)
    }
    func getPost(postId: Int) async throws -> WordpressPostDto {
        let urlString = "\(baseUrl)aktuell/postById/\(postId)"
        return try await HttpUtil.shared.performGetRequest(urlString: urlString, keyDecodingStrategy: .convertFromSnakeCase)
    }
    
    func getEvents(calendarId: String, includePast: Bool, maxResults: Int) async throws -> GoogleCalendarEventsDto {
        if !includePast {
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            let dateString = dateFormatter.string(from: Date.now)
            let urlString = "\(baseUrl)events/byCalendarId?calendarId=\(calendarId)&timeMin=\(dateString)&maxResults=\(maxResults)"
            return try await HttpUtil.shared.performGetRequest(urlString: urlString)
        }
        let urlString = "\(baseUrl)events/byCalendarId?calendarId=\(calendarId)&maxResults=\(maxResults)"
        return try await HttpUtil.shared.performGetRequest(urlString: urlString)
    }
    func getEvents(calendarId: String, pageToken: String, maxResults: Int) async throws -> GoogleCalendarEventsDto {
        let urlString = "\(baseUrl)events/byPageId?calendarId=\(calendarId)&pageToken=\(pageToken)&maxResults=\(maxResults)"
        return try await HttpUtil.shared.performGetRequest(urlString: urlString)
    }
    func getEvents(calendarId: String, timeMin: Date) async throws -> GoogleCalendarEventsDto {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let dateString = dateFormatter.string(from: timeMin)
        let urlString = "\(baseUrl)events/byCalendarId?calendarId=\(calendarId)&timeMin=\(dateString)"
        return try await HttpUtil.shared.performGetRequest(urlString: urlString)
    }
    func getEvent(calendarId: String, eventId: String) async throws -> GoogleCalendarEventDto {
        let urlString = "\(baseUrl)events/byEventId?calendarId=\(calendarId)&eventId=\(eventId)"
        return try await HttpUtil.shared.performGetRequest(urlString: urlString)
    }
    
    func getWeather() async throws -> WeatherDto {
        let urlString = "\(baseUrl)weather"
        return try await HttpUtil.shared.performGetRequest(urlString: urlString)
    }
    
    func getPhotosPfadijahre() async throws -> [WordpressPhotoGalleryDto] {
        let urlString = "\(baseUrl)photos/pfadijahre"
        return try await HttpUtil.shared.performGetRequest(urlString: urlString)
    }
    func getPhotosAlbums(id: String) async throws -> [WordpressPhotoGalleryDto] {
        let urlString = "\(baseUrl)photos/albums/\(id)"
        return try await HttpUtil.shared.performGetRequest(urlString: urlString)
    }
    func getPhotos(id: String) async throws -> [WordpressPhotoDto] {
        let urlString = "\(baseUrl)photos/images/\(id)"
        return try await HttpUtil.shared.performGetRequest(urlString: urlString)
    }
    
    func getDocuments() async throws -> [WordpressDocumentDto] {
        let urlString = "\(baseUrl)documents/downloads"
        return try await HttpUtil.shared.performGetRequest(urlString: urlString, keyDecodingStrategy: .convertFromSnakeCase)
    }
    func getLuuchtturm() async throws -> [WordpressDocumentDto] {
        let urlString = "\(baseUrl)documents/luuchtturm"
        return try await HttpUtil.shared.performGetRequest(urlString: urlString, keyDecodingStrategy: .convertFromSnakeCase)
    }
    
    func getLeitungsteam() async throws -> [LeitungsteamDto] {
        let urlString = "\(baseUrl)leitungsteam/members"
        return try await HttpUtil.shared.performGetRequest(urlString: urlString, keyDecodingStrategy: .convertFromSnakeCase)
    }
}
