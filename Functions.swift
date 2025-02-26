//
//  Functions.swift
//  Pathwise
//
//  Created by Zhang Hongliang on 21/2/25.
//
import Foundation

// MARK: - Finds the neighbouring cell thats part of the solution

func getNeighbourSolution(Origin: Cell, SolutionTuple: [(Destination: Cell, Origin: Cell?, Distance: CGFloat, Cost: CGFloat)]) -> (Up: Bool, Down: Bool, Left: Bool, Right: Bool) {
    var up: Bool = false
    var down: Bool = false
    var left: Bool = false
    var right: Bool = false
    // Up
    if SolutionTuple.first(where: { c in
        c.Destination.x == Origin.x && c.Destination.y == Origin.y - 1
    }) != nil {
        up = true
    }
    
    // Down
    if SolutionTuple.first(where: { c in
        c.Destination.x == Origin.x && c.Destination.y == Origin.y + 1
    }) != nil {
        down = true
    }

    //Left
    if SolutionTuple.first(where: { c in
        c.Destination.x == Origin.x - 1 && c.Destination.y == Origin.y
    }) != nil {
        left = true
    }

    // Right
    if SolutionTuple.first(where: { c in
        c.Destination.x == Origin.x + 1 && c.Destination.y == Origin.y
    }) != nil {
        right = true
    }

    
    
    return (up, down, left, right)
}

// MARK: - Function that updates a given cell and returns the updated array of the input

func updateCellArray(Cell: Cell, Array: [Cell]) async -> [Cell] {
    var mazeArray: [Cell] = Array
    mazeArray.removeAll { c in
        c.x == Cell.x && c.y == Cell.y
    }
    mazeArray.append(Cell)
    return mazeArray
}

func updateSolutionTuple(Tuple: (Destination: Cell, Origin: Cell?, Distance: CGFloat, Cost: CGFloat), SolutionTuple: [(Destination: Cell, Origin: Cell?, Distance: CGFloat, Cost: CGFloat)]) -> [(Destination: Cell, Origin: Cell?, Distance: CGFloat, Cost: CGFloat)] {
    var solutions = SolutionTuple
    solutions.removeAll { t in
        t.Destination.x == Tuple.Destination.x && t.Destination.y == Tuple.Destination.y
    }
    solutions.append(Tuple)
    return solutions
}

func updatePriorityQueue_PQEntry(priorityQueueEntry: PriorityQEntry, priorityQueue: [PriorityQEntry], Index: Int) -> [PriorityQEntry] {
    var solutions = priorityQueue
    solutions.removeAll { t in
        t.vertex.x == priorityQueueEntry.vertex.x && t.vertex.y == priorityQueueEntry.vertex.y
    }
    solutions.insert(priorityQueueEntry, at: Index)
    return solutions
}

func updatePriorityQueue_Cell(newVertex: Cell, priorityQueue: [PriorityQEntry]) async -> [PriorityQEntry] {
    var pQ = priorityQueue
    if var entry = pQ.first(where: { pqEntry in
        pqEntry.vertex.x == newVertex.x && pqEntry.vertex.y == newVertex.y
    }) {
        pQ.removeAll(where: { pqEntry in
            pqEntry.vertex.x == newVertex.x && pqEntry.vertex.y == newVertex.y
        })
        entry.vertex = newVertex
        pQ.append(entry)
    }
    return pQ
}


// MARK: - Function that finds the neighbouring cells of a given cell

func findNeighbouringCells(selectedCell: Cell, mazeCells: [Cell]) async -> [Cell] {
    var neighbourCells: [Cell] = []
    //Only accept cells who is not visited, visted = false
    if selectedCell.down {
        if let neighbour = mazeCells.first(where: { c in
            c.x == selectedCell.x && c.y == selectedCell.y+1
        }){
            if !neighbour.visited {
                neighbourCells.append(neighbour)
            }
        }
    }
    
    if selectedCell.up {
        if let neighbour = mazeCells.first(where: { c in
            c.x == selectedCell.x && c.y == selectedCell.y-1
        }){
            if !neighbour.visited {
                neighbourCells.append(neighbour)
            }
        }
    }
    
    if selectedCell.left {
        if let neighbour = mazeCells.first(where: { c in
            c.x == selectedCell.x-1 && c.y == selectedCell.y
        }){
            if !neighbour.visited {
                neighbourCells.append(neighbour)
            }
        }
    }
    
    if selectedCell.right {
        if let neighbour = mazeCells.first(where: { c in
            c.x == selectedCell.x+1 && c.y == selectedCell.y
        }){
            if !neighbour.visited {
                neighbourCells.append(neighbour)
            }
        }
    }
    return neighbourCells
}

func findNeighbourCellPQEntry(neighbourCells: [Cell], priorityQueue: [PriorityQEntry]) async -> [PriorityQEntry] {
    var neighbourPQEntry: [PriorityQEntry] = []
    for neighbourCell in neighbourCells {
        if let neighbourPQ = priorityQueue.first(where: { pq in
            pq.vertex.x == neighbourCell.x && pq.vertex.y == neighbourCell.y
        }) {
            neighbourPQEntry.append(neighbourPQ)
        }
    }
    return neighbourPQEntry
}


