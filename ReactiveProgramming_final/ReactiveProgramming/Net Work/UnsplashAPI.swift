//
//  UnsplashAPI.swift
//  ReactiveProgramming
//
//  Created by Hut on 2020/12/24.
//  Copyright © 2020 com.stoull.hut. All rights reserved.
//

import Foundation
import Combine

enum UnsplashAPI {
    static let accessToken = "L8pzY1XRm4REa02L-kiLW6nffk_4JMljIhz8rlF4Taw"
    static func randomImage() -> AnyPublisher<RandomImageResponse, GameError> {
        let url = URL(string: "https://api.unsplash.com/photos/random/?client_id=\(accessToken)")!
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        request.addValue("Accept-Version", forHTTPHeaderField: "v1")
        
        return session.dataTaskPublisher(for: request)
            .tryMap { response in
                guard let httpURLResponse = response.response as? HTTPURLResponse,
                      httpURLResponse.statusCode == 200
                else {
                    throw GameError.statusCode
                }
                return response.data
            }
            .decode(type: RandomImageResponse.self, decoder: JSONDecoder())
            .mapError{GameError.map($0)}
            .eraseToAnyPublisher()
    }
    
//    static func randomImage(completion: @escaping (RandomImageResponse?) -> Void) {
//        let url = URL(string: "https://api.unsplash.com/photos/random/?client_id=\(accessToken)")!
//
//        let config = URLSessionConfiguration.default
//        config.requestCachePolicy = .reloadIgnoringCacheData
//        config.urlCache = nil
//        let session = URLSession(configuration: config)
//
//        var request = URLRequest(url: url)
//        request.addValue("Accept-Version", forHTTPHeaderField: "v1")
//
//        session.dataTask(with: request) { (data, response, error) in
//            guard
//                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
//                let data = data, error == nil,
//                let decodedResponse = try? JSONDecoder().decode(RandomImageResponse.self, from: data)
//            else {
//                print("UnsplashAPI failed")
//                completion(nil)
//                return
//            }
//            print("UnsplashAPI successful: \(decodedResponse)")
//            completion(decodedResponse)
//        }.resume()
//    }
}
