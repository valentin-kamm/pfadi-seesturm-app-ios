//
//  WordpressService.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 31.01.2025.
//
import Foundation

class WordpressService {
    
    func fetchFromWordpress<T, R>(
        fetchAction: @escaping () async throws -> T,
        transform: @escaping (T) throws -> R
    ) async ->  SeesturmResult<R, NetworkError> {
        
        do {
            let response = try await fetchAction()
            let transformedResponse = try transform(response)
            return .success(transformedResponse)
        }
        catch let error as PfadiSeesturmError {
            switch error {
            case .invalidUrl(_):
                return .error(.invalidUrl)
            case .invalidHttpResponse(code: let code, _):
                return .error(.invalidRequest(httpCode: code))
            case .invalidResponse(message: _):
                return .error(.invalidData)
            case .dateError(message: _):
                return .error(.invalidDate)
            case .messagingPermissionError(_), .unknownStufe(_), .unknownNotificationTopic(_), .unknownAktivitaetInteraction(_), .authError(_), .cancelled(_), .unknown(_), .unknownSchoepflialarmReactionType(_), .jpgConversion(_):
                return .error(.unknown)
            }
        }
        catch let error as URLError {
            if error.code == .notConnectedToInternet {
                return .error(.ioException)
            }
            else if error.code == .cancelled {
                return .error(.cancelled)
            }
            else {
                return .error(.unknown)
            }
        }
        catch {
            return .error(.unknown)
        }
    }
}
