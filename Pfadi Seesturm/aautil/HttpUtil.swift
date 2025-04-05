//
//  HttpUtil.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 11.01.2025.
//
import Foundation

class HttpUtil {
    
    static let shared = HttpUtil()
    
    private init() {}
    
    func performGetRequest<T: Decodable>(
        urlString: String,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        headers: [HttpHeader]? = nil
    ) async throws -> T {
        
        // artificial delay
        try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Double.random(in: Constants.MIN_ARTIFICIAL_DELAY...Constants.MAX_ARTIFICIAL_DELAY)))
        
        // make sure url is valid
        guard let url = URL(string: urlString) else {
            throw PfadiSeesturmError.invalidUrl(message: "Die URL " + urlString + " ist ungültig.")
        }
        
        // create request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // add headers
        if let headers = headers {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        // perform request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // check response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PfadiSeesturmError.invalidResponse(message: "Ungültige Antwort vom Server (keine gültige HTTP-Antwort).")
        }
        guard httpResponse.statusCode == 200 else {
            throw PfadiSeesturmError.invalidHttpResponse(code: httpResponse.statusCode, message: "Ungültige Antwort vom Server (keine gültige HTTP-Antwort).")
        }
        
        // check that data is not empty
        guard !data.isEmpty else {
            throw PfadiSeesturmError.invalidResponse(message: "Die vom Server übermittelten Daten sind leer.")
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = keyDecodingStrategy
        return try decoder.decode(T.self, from: data)
        
    }
}

struct HttpHeader {
    let value: String
    let key: String
}


/*
 // function to perform a get request
 func performGetRequest<T: Decodable>(
     urlString: String,
     keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
 ) async throws -> T {
     
     // artificial delay
     try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 * Double.random(in: Constants.MIN_ARTIFICIAL_DELAY...Constants.MAX_ARTIFICIAL_DELAY)))
     
     // make sure url is valid
     guard let url = URL(string: urlString) else {
         throw PfadiSeesturmError.invalidUrl(message: "Die URL " + urlString + " ist ungültig.")
     }
     
     // Make network call
     let (data, response) = try await URLSession.shared.data(from: url)
     
     // check response
     guard let httpResponse = response as? HTTPURLResponse else {
         throw PfadiSeesturmError.invalidResponse(message: "Ungültige Antwort vom Server (keine gültige HTTP-Antwort).")
     }
     guard httpResponse.statusCode == 200 else {
         throw PfadiSeesturmError.invalidHttpResponse(code: httpResponse.statusCode, message: "Ungültige Antwort vom Server (keine gültige HTTP-Antwort).")
     }
     
     // check that data is not empty
     guard !data.isEmpty else {
         throw PfadiSeesturmError.invalidResponse(message: "Die vom Server übermittelten Daten sind leer.")
     }
     
     let decoder = JSONDecoder()
     decoder.keyDecodingStrategy = keyDecodingStrategy
     return try decoder.decode(T.self, from: data)
 }
 */
