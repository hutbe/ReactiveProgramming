//
//  GameError.swift
//  ReactiveProgramming
//
//  Created by Hut on 2020/12/24.
//  Copyright © 2020 com.stoull.hut. All rights reserved.
//

import Foundation

enum GameError: Error {
    case statusCode
    case decoding
    case invalidImage
    case invalidURL
    case other(Error)
    
    static func map(_ error: Error) -> GameError {
        return (error as? GameError) ?? .other(error)
    }
}
