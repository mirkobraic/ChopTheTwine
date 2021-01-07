//
//  LevelParser.swift
//  ChopTheTwine
//
//  Created by Mirko Braic on 07/01/2021.
//

import UIKit

class LevelParser {
    func parseLevel(withName levelName: String) -> LevelData {
//        guard let levelURL = Bundle.main.url(forResource: levelName, withExtension: "txt") else {
//            fatalError("Could not find \(levelName).txt in the app bundle.")
//        }
//        guard let levelString = try? String(contentsOf: levelURL) else {
//            fatalError("Could not load level1.txt from the app bundle.")
//        }
        
        return LevelData(crocodileLocation: CGPoint(x: 100, y: 300), prizeLocation: CGPoint(x: 200, y: 300), anchorLocations: [CGPoint(x: 150, y: 600), CGPoint(x: 250, y: 400)])
    }
}
