//
//  UnsplashAPI.swift
//  ReactiveProgramming
//
//  Created by Hut on 2020/12/24.
//  Copyright © 2020 com.stoull.hut. All rights reserved.
//

import Foundation

enum UnsplashAPI {
    static let accessToken = "L8pzY1XRm4REa02L-kiLW6nffk_4JMljIhz8rlF4Taw"
    
    static func randomImage(completion: @escaping (RandomImageResponse?) -> Void) {
        let url = URL(string: "https://api.unsplash.com/photos/random/?client_id=\(accessToken)")!
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        request.addValue("Accept-Version", forHTTPHeaderField: "v1")
        
        session.dataTask(with: request) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil,
                let decodedResponse = try? JSONDecoder().decode(RandomImageResponse.self, from: data)
            else {
                print("UnsplashAPI failed")
                completion(nil)
                return
            }
            print("UnsplashAPI successful: \(decodedResponse)")
            completion(decodedResponse)
        }.resume()
    }
}
