//
//  LevelParser.swift
//  ChopTheTwine
//
//  Created by Mirko Braic on 07/01/2021.
//

import UIKit

class LevelParser {
    func parseLevel(withName levelName: String, screenSize: CGSize, groundOffset: CGFloat) -> LevelData {
        let name = (levelName as NSString).deletingPathExtension
        
        guard let levelURL = Bundle.main.url(forResource: name, withExtension: "txt") else {
            fatalError("Could not find \(levelName).txt in the app bundle.")
        }
        guard let levelString = try? String(contentsOf: levelURL) else {
            fatalError("Could not load level1.txt from the app bundle.")
        }
        
        var lines = levelString.components(separatedBy: "\n")
        // remove empty line
        lines.removeLast()
        
        // ensure that level is at least 3x3
        guard lines.count >= 5, lines[0].count >= 6 else {
            fatalError("Invalid level format")
        }
        
        let heightQuant = (screenSize.height - groundOffset) / CGFloat(lines.count)
        let widthQuant = screenSize.width / CGFloat(lines[0].count)
        
        // remove first and last **** lines
        lines.removeFirst()
        lines.removeLast()
        
        var levelData = LevelData()
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let x = widthQuant * CGFloat(column)
                let y = heightQuant * CGFloat(row) + groundOffset
                let position = CGPoint(x: x, y: y)
                
                if letter == "a" {
                    levelData.anchorLocations.append(position)
                } else if letter == "p" {
                    levelData.prizeLocation = position
                } else if letter == "c" {
                    levelData.crocodileLocation = position
                }
            }
        }
        
        return levelData
    }
}
