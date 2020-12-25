//
//  ImageDownloader.swift
//  ReactiveProgramming
//
//  Created by Hut on 2020/12/24.
//  Copyright © 2020 com.stoull.hut. All rights reserved.
//

import Foundation
import UIKit
import Combine

struct ImageDownloader {
    static func downloadImage(url: String) -> AnyPublisher<UIImage?, GameError> {
        guard let imageURL = URL(string: url) else {
            return Fail(error: GameError.invalidURL)
                .eraseToAnyPublisher()
        }
        var request = URLRequest(url: imageURL)
        request.timeoutInterval = 120
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { response -> Data in
                guard let httpUrlResponse = response.response as? HTTPURLResponse,
                      httpUrlResponse.statusCode == 200
                else {
                    throw GameError.statusCode
                }
                return response.data
            }
            .tryMap { data in
                guard let image = UIImage(data: data) else {
                    throw GameError.invalidImage
                }
                return image
            }
            .mapError { GameError.map($0) }
            .eraseToAnyPublisher()
    }
    
//    static func downloadImage(url: String, completion: @escaping (UIImage?) -> Void) {
//        guard let imageURL = URL(string: url) else {
//            completion(nil)
//            return
//        }
//        var request = URLRequest(url: imageURL)
//        request.timeoutInterval = 120
//        URLSession.shared.dataTask(with: request) { (data, response, error) in
//            guard let httpURLResponse = response as? HTTPURLResponse,
//                  httpURLResponse.statusCode == 200,
//                  let data = data, error == nil,
//                  let image = UIImage(data: data)
//            else {
//                print("failed download image")
//                completion(nil)
//                return
//            }
//            print("Successful download image")
//            completion(image)
//        }.resume()
//    }
}
