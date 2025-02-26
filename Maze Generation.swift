//
//  Cell.swift
//  Pathwise
//
//  Created by Zhang Hongliang on 13/2/25.
//

import Foundation

func generateMaze(randomness: Int) async -> [Cell]?{
    var visitedCells: [Cell] = []
    var nonVisitedCells: [Cell] = []
    var randomnessTicker = 0
    var neighbourCell: Cell?
    for x in 1...10 {
        for y in 1...10 {
            let cell = Cell.init(x: x, y: y, up: false, down: false, left: false, right: false, visited: x == 1 && y == 1 ? true : false, solution: false)
            if cell.visited {
                visitedCells.append(cell)
            } else {
                nonVisitedCells.append(cell)
            }
            
        }
    }
    while !nonVisitedCells.isEmpty {
        // Checks Neighbouring Cells
        if let mostRecentlyVisitedCell = visitedCells.last {
            var neighbourCells:[Cell?] = []
            //LEFT
            neighbourCells.append(nonVisitedCells.first(where: { c in
                c.x == mostRecentlyVisitedCell.x - 1 && c.y == mostRecentlyVisitedCell.y
            }))
            //RIGHT
            neighbourCells.append(nonVisitedCells.first(where: { c in
                c.x == mostRecentlyVisitedCell.x + 1 && c.y == mostRecentlyVisitedCell.y
            }))
            //TOP
            neighbourCells.append(nonVisitedCells.first(where: { c in
                c.x == mostRecentlyVisitedCell.x && c.y == mostRecentlyVisitedCell.y - 1
            }))
            //BOTTOM
            neighbourCells.append(nonVisitedCells.first(where: { c in
                c.x == mostRecentlyVisitedCell.x && c.y == mostRecentlyVisitedCell.y + 1
            }))
            let mappedNeighbourCells = neighbourCells.compactMap {$0}
            if !mappedNeighbourCells.isEmpty {
                var neighbourCell = mappedNeighbourCells.randomElement()!
                var currentCell = mostRecentlyVisitedCell
                neighbourCell.visited = true
                
                switch neighbourCell.x - mostRecentlyVisitedCell.x {
                case -1:
                    currentCell.left = true
                    neighbourCell.right = true
                case 1 :
                    currentCell.right = true
                    neighbourCell.left = true
                default:
                    print("X Axis no change")
                }
                
                switch neighbourCell.y - mostRecentlyVisitedCell.y {
                case -1:
                    currentCell.up = true
                    neighbourCell.down = true
                case 1 :
                    currentCell.down = true
                    neighbourCell.up = true
                default:
                    print("Y Axis no change")
                }
                visitedCells.removeLast()
                visitedCells.append(currentCell)
                visitedCells.append(neighbourCell)
                nonVisitedCells.removeAll { c in
                    c.x == neighbourCell.x && c.y == neighbourCell.y
                }
            } else {
                visitedCells.removeLast()
                visitedCells.insert(mostRecentlyVisitedCell, at: 0)
            }
        } else {
            print("Problem at Maze generation, Visited Cell EMPTY")
        }
    }
    
    // Make it not a perfect maze
    while randomnessTicker != randomness {
        var randomCell = visitedCells.randomElement()!
        //Checking if it is the corners
        if randomCell.x == 1 && randomCell.y == 1 { //Upper left corner piece
            if !randomCell.right {
                neighbourCell = visitedCells.first { c in
                    c.x == 2 && c.y == 1
                }
                randomCell.right = true
                neighbourCell?.left = true
            }
            
            if !randomCell.down {
                neighbourCell = visitedCells.first { c in
                    c.x == 1 && c.y == 2
                }
                randomCell.down = true
                neighbourCell?.up = true
            }
        }
        
        if randomCell.x == 10 && randomCell.y == 1 { //Upper right corner piece
            if !randomCell.left {
                neighbourCell = visitedCells.first { c in
                    c.x == 9 && c.y == 1
                }
                randomCell.left = true
                neighbourCell?.right = true
            }
            
            if !randomCell.down {
                neighbourCell = visitedCells.first { c in
                    c.x == 10 && c.y == 2
                }
                randomCell.down = true
                neighbourCell?.up = true
            }
        }
        
        if randomCell.x == 1 && randomCell.y == 10 { //Lower left corner piece
            if !randomCell.right {
                neighbourCell = visitedCells.first { c in
                    c.x == 2 && c.y == 10
                }
                randomCell.right = true
                neighbourCell?.left = true
            }
            
            if !randomCell.up {
                neighbourCell = visitedCells.first { c in
                    c.x == 1 && c.y == 9
                }
                randomCell.up = true
                neighbourCell?.down = true
            }
        }
        
        if randomCell.x == 10 && randomCell.y == 10 { //Lower right corner piece
            if !randomCell.left {
                neighbourCell = visitedCells.first { c in
                    c.x == 9 && c.y == 10
                }
                randomCell.left = true
                neighbourCell?.right = true
            }
            
            if !randomCell.up {
                neighbourCell = visitedCells.first { c in
                    c.x == 10 && c.y == 9
                }
                randomCell.up = true
                neighbourCell?.down = true
            }
        }
        
        // Checking Edges
        if randomCell.x == 1 && (2..<10).contains(randomCell.y) { // Left Edge
            var directions: [String] = []
            if !randomCell.up {
                directions.append("up")
            }
            if !randomCell.down {
                directions.append("down")
            }
            if !randomCell.right {
                directions.append("right")
            }
            let modifyDirection = directions.randomElement() ?? "nothing"
            
            switch modifyDirection {
            case "up":
                neighbourCell = visitedCells.first { c in
                    c.x == randomCell.x && c.y == randomCell.y-1
                }
                randomCell.up = true
                neighbourCell?.down = true
            case "down":
                neighbourCell = visitedCells.first { c in
                    c.x == randomCell.x && c.y == randomCell.y+1
                }
                randomCell.down = true
                neighbourCell?.up = true
            case "right":
                neighbourCell = visitedCells.first { c in
                    c.x == randomCell.x+1 && c.y == randomCell.y
                }
                randomCell.right = true
                neighbourCell?.left = true
                
            case "nothing":
                print("Cell has maximum connections")
                
            default:
                print("Left Edge fail")
            }
            
        }
        
        if randomCell.x == 10 && (2..<10).contains(randomCell.y) { // Right Edge
            var directions: [String] = []
            if !randomCell.up {
                directions.append("up")
            }
            if !randomCell.down {
                directions.append("down")
            }
            if !randomCell.left {
                directions.append("left")
            }
            let modifyDirection = directions.randomElement() ?? "nothing"
            
            switch modifyDirection {
            case "up":
                neighbourCell = visitedCells.first { c in
                    c.x == randomCell.x && c.y == randomCell.y-1
                }
                randomCell.up = true
                neighbourCell?.down = true
            case "down":
                neighbourCell = visitedCells.first { c in
                    c.x == randomCell.x && c.y == randomCell.y+1
                }
                randomCell.down = true
                neighbourCell?.up = true
            case "left":
                neighbourCell = visitedCells.first { c in
                    c.x == randomCell.x-1 && c.y == randomCell.y
                }
                randomCell.left = true
                neighbourCell?.right = true
                
            case "nothing":
                print("Cell has maximum connections")
                
            default:
                print("Right Edge fail")
            }
            
        }
        
        if randomCell.y == 10 && (2..<10).contains(randomCell.x) { // Bottom Edge
            var directions: [String] = []
            if !randomCell.up {
                directions.append("up")
            }
            if !randomCell.right {
                directions.append("right")
            }
            if !randomCell.left {
                directions.append("left")
            }
            let modifyDirection = directions.randomElement() ?? "nothing"
            
            switch modifyDirection {
            case "up":
                neighbourCell = visitedCells.first { c in
                    c.x == randomCell.x && c.y == randomCell.y-1
                }
                randomCell.up = true
                neighbourCell?.down = true
            case "right":
                neighbourCell = visitedCells.first { c in
                    c.x == randomCell.x+1 && c.y == randomCell.y
                }
                randomCell.right = true
                neighbourCell?.left = true
            case "left":
                neighbourCell = visitedCells.first { c in
                    c.x == randomCell.x-1 && c.y == randomCell.y
                }
                randomCell.left = true
                neighbourCell?.right = true
                
            case "nothing":
                print("Cell has maximum connections")
                
            default:
                print("Bottom Edge fail")
            }
            
        }
        
        if randomCell.y == 1 && (2..<10).contains(randomCell.x) { // Top Edge
            var directions: [String] = []
            if !randomCell.down {
                directions.append("down")
            }
            if !randomCell.right {
                directions.append("right")
            }
            if !randomCell.left {
                directions.append("left")
            }
            let modifyDirection = directions.randomElement() ?? "nothing"
            
            switch modifyDirection {
            case "down":
                neighbourCell = visitedCells.first { c in
                    c.x == randomCell.x && c.y == randomCell.y+1
                }
                randomCell.down = true
                neighbourCell?.up = true
            case "right":
                neighbourCell = visitedCells.first { c in
                    c.x == randomCell.x+1 && c.y == randomCell.y
                }
                randomCell.right = true
                neighbourCell?.left = true
            case "left":
                neighbourCell = visitedCells.first { c in
                    c.x == randomCell.x-1 && c.y == randomCell.y
                }
                randomCell.left = true
                neighbourCell?.right = true
                
            case "nothing":
                print("Cell has maximum connections")
                
            default:
                print("Top Edge fail")
            }
            
        }
        
        //The rest of the cells
        if (2..<10).contains(randomCell.y) && (2..<10).contains(randomCell.x) {
            var directions: [String] = []
            if !randomCell.up {
                directions.append("up")
            }
            if !randomCell.down {
                directions.append("down")
            }
            if !randomCell.right {
                directions.append("right")
            }
            if !randomCell.left {
                directions.append("left")
            }
            let modifyDirection = directions.randomElement() ?? "nothing"
            
            switch modifyDirection {
            case "up":
                neighbourCell = visitedCells.first { c in
                    c.x == randomCell.x && c.y == randomCell.y-1
                }
                randomCell.up = true
                neighbourCell?.down = true
            case "down":
                neighbourCell = visitedCells.first { c in
                    c.x == randomCell.x && c.y == randomCell.y+1
                }
                randomCell.down = true
                neighbourCell?.up = true
            case "right":
                neighbourCell = visitedCells.first { c in
                    c.x == randomCell.x+1 && c.y == randomCell.y
                }
                randomCell.right = true
                neighbourCell?.left = true
            case "left":
                neighbourCell = visitedCells.first { c in
                    c.x == randomCell.x-1 && c.y == randomCell.y
                }
                randomCell.left = true
                neighbourCell?.right = true
                
            case "nothing":
                print("Cell has maximum connections")
                
            default:
                print("Rest of the cells fail")
            }
        }

            
        visitedCells.removeAll { c in
            c.x == randomCell.x && c.y == randomCell.y
        }
        visitedCells.removeAll { c in
            c.x == neighbourCell?.x && c.y == neighbourCell?.y
        }
        visitedCells.append(randomCell)
        visitedCells.append(neighbourCell ?? Cell(x: 1, y: 1))
        randomnessTicker += 1
        print("Currently on loop \(randomnessTicker), have modified these cells:")
        print(randomCell)
        print(neighbourCell ?? "Dafqu how you get this to be nil???")
    }
    
    
    return visitedCells
}
