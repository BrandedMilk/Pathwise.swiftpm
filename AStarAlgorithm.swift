//
//  AStarAlgorithm.swift
//  Maze Theory
//
//  Created by Zhang Hongliang on 15/12/23.
//

import Foundation
import CoreGraphics

func aStarAlgorithm(cells: [Cell], start: CGPoint, end: CGPoint) async -> (Solution: [Cell], Distance: CGFloat, SolutionTuple: [(Destination: Cell, Origin: Cell?, Distance: CGFloat, Cost: CGFloat)]) {
    //Initialise Variables
    let xStart = Int(start.x)
    let yStart = Int(start.y)
    let xEnd = Int(end.x)
    let yEnd = Int(end.y)
    let mazeCells = cells
    var destinationCell: (Destination: Cell, Origin: Cell?, Distance: CGFloat, Cost: CGFloat)
    var priorityQueue: [(Destination: Cell, Origin: Cell?, Distance: CGFloat, Cost: CGFloat)] = []
    var visitedNodes: [(Destination: Cell, Origin: Cell?, Distance: CGFloat, Cost: CGFloat)] = []
    
    //Constructs Priority Queue
    // Cost = Distance + Heuristic
    // Distance = Path combined weight
    for mazeCell in mazeCells {
        priorityQueue.append((Destination: mazeCell, Origin: nil, Distance: mazeCell.x == xStart && mazeCell.y == yStart ? 0 : 10000, Cost: mazeCell.x == xStart && mazeCell.y == yStart ? getEuclideanDistance(current: start, end: end) : 10000))
        print(priorityQueue.last?.Distance as Any)
    }
    priorityQueue.sort { $0.Cost < $1.Cost }
    //print("This is the priority queue \(priorityQueue)")
    
    while !(priorityQueue.first?.Destination.x == xEnd && priorityQueue.first?.Destination.y == yEnd) {
        var cost: CGFloat
        var pathCost: CGFloat
        if let firstInQueue = priorityQueue.first {
            let currentCell = firstInQueue.Destination
            //Down
            if currentCell.down {
                if let neighbourCell = mazeCells.first(where: { c in c.x == currentCell.x && c.y == currentCell.y + 1}) {
                    pathCost = 1 + firstInQueue.Distance
                    cost = pathCost + getEuclideanDistance(current: CGPoint(x: neighbourCell.x, y: neighbourCell.y), end: CGPoint(x: xEnd, y: yEnd))
                    if var neighbouringTuple = priorityQueue.first(where: { tuple in tuple.Destination.x == neighbourCell.x && tuple.Destination.y == neighbourCell.y}) {
                        if neighbouringTuple.Distance > pathCost{
                            neighbouringTuple.Distance = pathCost
                            neighbouringTuple.Cost = cost
                            neighbouringTuple.Origin = currentCell
                            priorityQueue.removeAll { c in
                                c.Destination.x == neighbouringTuple.Destination.x &&  c.Destination.y == neighbouringTuple.Destination.y
                            }
                            priorityQueue.append(neighbouringTuple)
                        }
                    }
                }
                
            }
            //Up
            if currentCell.up {
                if let neighbourCell = mazeCells.first(where: { c in c.x == currentCell.x && c.y == currentCell.y - 1}) {
                    pathCost = 1 + firstInQueue.Distance
                    cost = 1 + getEuclideanDistance(current: CGPoint(x: neighbourCell.x, y: neighbourCell.y), end: CGPoint(x: xEnd, y: yEnd))
                    if var neighbouringTuple = priorityQueue.first(where: { tuple in tuple.Destination.x == neighbourCell.x && tuple.Destination.y == neighbourCell.y}) {
                        if neighbouringTuple.Distance > pathCost{
                            neighbouringTuple.Distance = pathCost
                            neighbouringTuple.Cost = cost
                            neighbouringTuple.Origin = currentCell
                            priorityQueue.removeAll { c in
                                c.Destination.x == neighbouringTuple.Destination.x && c.Destination.y == neighbouringTuple.Destination.y
                            }
                            priorityQueue.append(neighbouringTuple)
                            
                        }
                    }
                }
                
            }
            //Left
            if currentCell.left {
                if let neighbourCell = mazeCells.first(where: { c in c.x == currentCell.x - 1 && c.y == currentCell.y}) {
                    pathCost = 1 + firstInQueue.Distance
                    cost = 1 + getEuclideanDistance(current: CGPoint(x: neighbourCell.x, y: neighbourCell.y), end: CGPoint(x: xEnd, y: yEnd))
                    if var neighbouringTuple = priorityQueue.first(where: { tuple in tuple.Destination.x == neighbourCell.x && tuple.Destination.y == neighbourCell.y}) {
                        if neighbouringTuple.Distance > pathCost{
                            neighbouringTuple.Distance = pathCost
                            neighbouringTuple.Cost = cost
                            neighbouringTuple.Origin = currentCell
                            priorityQueue.removeAll { c in
                                c.Destination.x == neighbouringTuple.Destination.x &&  c.Destination.y == neighbouringTuple.Destination.y
                            }
                            priorityQueue.append(neighbouringTuple)
                            
                        }
                    }
                }
                
            }
            //Right
            if currentCell.right {
                if let neighbourCell = mazeCells.first(where: { c in c.x == currentCell.x + 1 && c.y == currentCell.y}) {
                    pathCost = 1 + firstInQueue.Distance
                    cost = 1 + getEuclideanDistance(current: CGPoint(x: neighbourCell.x, y: neighbourCell.y), end: CGPoint(x: xEnd, y: yEnd))
                    if var neighbouringTuple = priorityQueue.first(where: { tuple in tuple.Destination.x == neighbourCell.x && tuple.Destination.y == neighbourCell.y}) {
                        if neighbouringTuple.Distance > pathCost{
                            neighbouringTuple.Distance = pathCost
                            neighbouringTuple.Cost = cost
                            neighbouringTuple.Origin = currentCell
                            priorityQueue.removeAll { c in
                                c.Destination.x == neighbouringTuple.Destination.x && c.Destination.y == neighbouringTuple.Destination.y
                            }
                            priorityQueue.append(neighbouringTuple)
                            
                        }
                    }
                }
                
            }
            visitedNodes.append(firstInQueue)
            priorityQueue.removeFirst(1)
            //print(priorityQueue.removeFirst(1))
            priorityQueue.sort { $0.Cost < $1.Cost }
            //print("This is priorityQueue: \(priorityQueue)")
        }
    }
    destinationCell = priorityQueue[0]
    let allTuples = priorityQueue + visitedNodes
    return getSolutionPath(Destination: destinationCell, Tuple_Array: allTuples, Maze_Cells: mazeCells, Intial: start)
}

func getEuclideanDistance(current: CGPoint, end: CGPoint) -> CGFloat {
    let xDistance = abs(current.x - end.x)
    let yDistance = abs(current.y - end.y)
    let euclideanDistance = sqrt(xDistance*xDistance + yDistance*yDistance)
    return euclideanDistance
}


// Changes solution variable to true
func getSolutionPath(Destination: (Destination: Cell, Origin: Cell?, Distance: CGFloat, Cost: CGFloat), Tuple_Array: [(Destination: Cell, Origin: Cell?, Distance: CGFloat, Cost: CGFloat)], Maze_Cells: [Cell], Intial: CGPoint) -> (Solution: [Cell], Distance: CGFloat,SolutionTuple: [(Destination: Cell, Origin: Cell?, Distance: CGFloat, Cost: CGFloat)]) {
    var destinationDistance = Destination.Distance
    var totalDistance: CGFloat = 0
    var investigatingCell: (Destination: Cell, Origin: Cell?, Distance: CGFloat, Cost: CGFloat) = Destination
    var destinationCell = investigatingCell.Destination
    var mazeCells = Maze_Cells
    var solutionTuples: [(Destination: Cell, Origin: Cell?, Distance: CGFloat, Cost: CGFloat)] = [Destination]
    print("Distance from Algorithm \(destinationDistance)")
    
    
    destinationCell.solution = true
    mazeCells.removeAll { c in
        c.x == destinationCell.x && c.y == destinationCell.y
    }
    mazeCells.append(destinationCell)
    
    if let inital = Maze_Cells.first(where: { c in
        c.x == Int(Intial.x) && c.y == Int(Intial.y)
    }) {
        while !(investigatingCell.Destination.x == inital.x && investigatingCell.Destination.y == inital.y) {
            if var origin = investigatingCell.Origin {
                origin.solution = true
                mazeCells.removeAll { c in
                    c.x == origin.x && c.y == origin.y
                }
                mazeCells.append(origin)
                if let tuple = Tuple_Array.first(where: { c in
                    c.Destination.x == origin.x && c.Destination.y == origin.y
                }) {
                    solutionTuples.append(tuple)
                    totalDistance += 1
                    investigatingCell = tuple
                }
            }
        }
    }
    if totalDistance == destinationDistance {
        print("Distance calculated is correct")
    } else {
        print("Destination Cell \(destinationDistance), total Distance \(totalDistance)")
    }
    
    return (mazeCells, totalDistance, solutionTuples)
}
