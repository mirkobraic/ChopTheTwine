//
//  GameConfigurationManager.swift
//  ChopTheTwine
//
//  Created by Mirko Braic on 05/01/2021.
//

import Foundation

class GameLevelManager {
    static let shared = GameLevelManager()
    
    var levels = [String]()
    
    private init() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        for item in items {
            if item.hasPrefix("Level"), item.hasSuffix(".txt"){
                levels.append(item)
            }
        }
    }
    
    func randomLevel() -> String {
        return levels.randomElement()!
    }
}
