//
//  AStarSolvedMazeView.swift
//  Pathwise
//
//  Created by Zhang Hongliang on 24/2/25.
//
import SwiftUI

struct AStarSolvedMazeView: View {
    @Binding var solutions: [(Destination: Cell, Origin: Cell?, Distance: CGFloat, Cost: CGFloat)] 
    @Binding var priorityQueue: [PriorityQEntry]
    @Binding var visitedVertices: [PriorityQEntry]
    @Binding var mazeCells: [Cell]
    @Binding var startCoor: CGPoint
    @Binding var endCoor: CGPoint
    @State var buttonCounter = 0
    @State var goalPQEntry: PriorityQEntry = PriorityQEntry(vertex: Cell(x: 10, y: 10), Distance: 1000)
    @State var solutionArray: [PriorityQEntry] = []
    @State var reachedStart = false
    @State var showEnd = false
    @State var totalDistance = 0
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(UIColor.systemGray6))
                .ignoresSafeArea()
            NavigationStack {
                ZStack(alignment: .bottom) {
                    VStack(alignment: .center) {
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("Now that the A* algorithm have finished running. It has reached the goal vertex of Cell(X:10,Y:10).")
                                .padding()
                            Text("Although, how do we know that is the shortest path to reach the goal from start?")
                                .padding()
                                .opacity(buttonCounter >= 1 ? 1 : 0)
                            Text("That it is what the path-via is for! It is like the chain that links the vertices in the solution path together.")
                                .padding()
                                .multilineTextAlignment(.leading)
                                .opacity(buttonCounter >= 2 ? 1 : 0)
                            if reachedStart {
                                Text("Yay! We have found the shortest path in this maze! The total distance is \(totalDistance)")
                                    .padding()
                            }
                        }
                        
                        ScrollViewReader { proxy in
                            ScrollView {
                                ForEach(solutionArray, id: \.self) { solutionVertex in
                                    VStack {
                                        HStack {
                                            Text("Vertex: Cell(X:\(solutionVertex.vertex.x),Y:\(solutionVertex.vertex.y))")
                                            Divider().frame(width: 1)
                                            Text(solutionVertex.originVertex != nil ? "Path-via vertex: Cell(X:\(solutionVertex.originVertex?.x ?? 0),Y:\(solutionVertex.originVertex?.y ?? 0))" : "We have reached the start!")
                                        }
                                        .padding()
                                        .frame(height: 60)
                                        .background(in: RoundedRectangle(cornerRadius: 10))
                                        Image(systemName: "arrow.down")
                                            .font(.system(size: 25))
                                            .foregroundStyle(.black)
                                            .padding()
                                    }.id(solutionVertex)
                                }
                                if !reachedStart {
                                    Text("...")
                                } else {
                                    Text("Done! We have reached the starting vertex!")
                                }
                            }.onChange(of: solutionArray) { oldValue, newValue in
                                if let newItem = solutionArray.last {
                                    withAnimation {
                                        proxy.scrollTo(newItem)
                                    }
                                }
                            }
                        }.opacity(buttonCounter == 2 ? 1 : 0)
                    }
                    if !reachedStart {
                        Button {
                            if buttonCounter != 2 {
                                withAnimation {
                                    buttonCounter += 1
                                }
                            } else {
                                if let goalEntryOrigin = goalPQEntry.originVertex {
                                    if var newSolutionEntry = visitedVertices.first(where: { pqEntry in
                                        pqEntry.vertex.x == goalEntryOrigin.x && pqEntry.vertex.y == goalEntryOrigin.y
                                    }) {
                                        newSolutionEntry.vertex.solution = true
                                        Task {
                                            mazeCells = await updateCellArray(Cell: newSolutionEntry.vertex, Array: mazeCells)
                                        }
                                        withAnimation {
                                            solutionArray.append(newSolutionEntry)
                                            solutions.append((Destination: newSolutionEntry.vertex, Origin: newSolutionEntry.originVertex, Distance: CGFloat(newSolutionEntry.Distance), Cost: newSolutionEntry.cost))
                                            goalPQEntry = newSolutionEntry
                                            if goalPQEntry.vertex.x == 1 && goalPQEntry.vertex.y == 1 {
                                                reachedStart = true
                                            }
                                        }
                                    }
                                }
                            }
                        } label: {
                            Text(buttonCounter == 2 ? "Search" : "Continue")
                                .frame(width: 210, height: 40, alignment: .center)
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(Color.blue))
                        }.padding(45)
                    } else if reachedStart {
                        Button {
                            withAnimation {
                                showEnd.toggle()
                            }
                        } label: {
                            Text("Finish")
                                .frame(width: 210, height: 40, alignment: .center)
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(Color.blue))
                        }.padding(45)
                    }
                }.onAppear {
                    Task {
                        //                let startTime = DispatchTime.now()
                        let results = await resumingAStarAlgorithm(priorityQueue: priorityQueue, visitedVertices: visitedVertices, mazeCells: mazeCells, startCoor: startCoor, endCoor: endCoor)
                        //                let endTime = DispatchTime.now()
                        //                let elapsedTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
                        //                print("\(Double(elapsedTime) / 1_000_000) miliseconds")
                        priorityQueue = results.priorityQueue
                        visitedVertices = results.visitedVertices
                        mazeCells = results.mazeCells
                        goalPQEntry = results.goalVertex
                        totalDistance = results.goalVertex.Distance
                        solutionArray.append(results.goalVertex)
                        solutions.append((Destination: results.goalVertex.vertex, Origin: results.goalVertex.originVertex, Distance: CGFloat(results.goalVertex.Distance), Cost: results.goalVertex.cost))
                    }
                }
            }
            .navigationTitle("Solving the maze with A* Algorithm")
            .navigationBarTitleDisplayMode(.inline)
            if showEnd {
                EndingView()
                    .transition(.move(edge: .trailing))
            }
        }
    }
}

func resumingAStarAlgorithm(priorityQueue: [PriorityQEntry], visitedVertices: [PriorityQEntry], mazeCells:[Cell], startCoor: CGPoint, endCoor: CGPoint) async -> (mazeCells: [Cell], priorityQueue: [PriorityQEntry], visitedVertices: [PriorityQEntry], goalVertex: PriorityQEntry) {
    var goalVertex = PriorityQEntry(vertex: Cell(x: 10, y: 10), Distance: 1000)
    var priorityQueue: [PriorityQEntry] = priorityQueue
    var visitedVertices: [PriorityQEntry] = visitedVertices
    var mazeCells: [Cell] = mazeCells
    let startCoor: CGPoint = startCoor
    let endCoor: CGPoint = endCoor
    
    priorityQueue.sort { pq1, pq2 in
        pq1.cost <= pq2.cost
    }

    while !(priorityQueue.first?.vertex.x == Int(endCoor.x) && priorityQueue.first?.vertex.y == Int(endCoor.y)) {
        var cost: CGFloat
        var distance: Int
        if var firstInQueue = priorityQueue.first {
            let currentCell = firstInQueue.vertex
            //Down
            if currentCell.down {
                if var neighbourCell = mazeCells.first(where: { c in c.x == currentCell.x && c.y == currentCell.y + 1}) {
                    distance = 1 + firstInQueue.Distance
                    cost = CGFloat(distance) + getEuclideanDistance(current: CGPoint(x: neighbourCell.x, y: neighbourCell.y), end: CGPoint(x: endCoor.x, y: endCoor.y))
                    if var neighbouringPQEntry = priorityQueue.first(where: { tuple in tuple.vertex.x == neighbourCell.x && tuple.vertex.y == neighbourCell.y}) {
                        if neighbouringPQEntry.cost > cost{
                            neighbouringPQEntry.cost = cost
                            neighbouringPQEntry.Distance = Int(distance)
                            neighbouringPQEntry.originVertex = currentCell
                            priorityQueue.removeAll { c in
                                c.vertex.x == neighbouringPQEntry.vertex.x &&  c.vertex.y == neighbouringPQEntry.vertex.y
                            }
                            priorityQueue.append(neighbouringPQEntry)
                        }
                    }
                    neighbourCell.visited = true
                    mazeCells = await updateCellArray(Cell: neighbourCell, Array: mazeCells)
                }
                
            }
            //Up
            if currentCell.up {
                if var neighbourCell = mazeCells.first(where: { c in c.x == currentCell.x && c.y == currentCell.y - 1}) {
                    distance = 1 + firstInQueue.Distance
                    cost = CGFloat(distance) + getEuclideanDistance(current: CGPoint(x: neighbourCell.x, y: neighbourCell.y), end: CGPoint(x: endCoor.x, y: endCoor.y))
                    if var neighbouringPQEntry = priorityQueue.first(where: { tuple in tuple.vertex.x == neighbourCell.x && tuple.vertex.y == neighbourCell.y}) {
                        if neighbouringPQEntry.cost > cost{
                            neighbouringPQEntry.cost = cost
                            neighbouringPQEntry.Distance = Int(distance)
                            neighbouringPQEntry.originVertex = currentCell
                            priorityQueue.removeAll { c in
                                c.vertex.x == neighbouringPQEntry.vertex.x &&  c.vertex.y == neighbouringPQEntry.vertex.y
                            }
                            priorityQueue.append(neighbouringPQEntry)
                        }
                    }
                    neighbourCell.visited = true
                    mazeCells = await updateCellArray(Cell: neighbourCell, Array: mazeCells)
                }
            }
            //Left
            if currentCell.left {
                if var neighbourCell = mazeCells.first(where: { c in c.x == currentCell.x-1 && c.y == currentCell.y}) {
                    distance = 1 + firstInQueue.Distance
                    cost = CGFloat(distance) + getEuclideanDistance(current: CGPoint(x: neighbourCell.x, y: neighbourCell.y), end: CGPoint(x: endCoor.x, y: endCoor.y))
                    if var neighbouringPQEntry = priorityQueue.first(where: { tuple in tuple.vertex.x == neighbourCell.x && tuple.vertex.y == neighbourCell.y}) {
                        if neighbouringPQEntry.cost > cost{
                            neighbouringPQEntry.cost = cost
                            neighbouringPQEntry.Distance = Int(distance)
                            neighbouringPQEntry.originVertex = currentCell
                            priorityQueue.removeAll { c in
                                c.vertex.x == neighbouringPQEntry.vertex.x &&  c.vertex.y == neighbouringPQEntry.vertex.y
                            }
                            priorityQueue.append(neighbouringPQEntry)
                        }
                    }
                    neighbourCell.visited = true
                    mazeCells = await updateCellArray(Cell: neighbourCell, Array: mazeCells)
                }
            }
            //Right
            if currentCell.right {
                if var neighbourCell = mazeCells.first(where: { c in c.x == currentCell.x+1 && c.y == currentCell.y}) {
                    distance = 1 + firstInQueue.Distance
                    cost = CGFloat(distance) + getEuclideanDistance(current: CGPoint(x: neighbourCell.x, y: neighbourCell.y), end: CGPoint(x: endCoor.x, y: endCoor.y))
                    if var neighbouringPQEntry = priorityQueue.first(where: { tuple in tuple.vertex.x == neighbourCell.x && tuple.vertex.y == neighbourCell.y}) {
                        if neighbouringPQEntry.cost > cost{
                            neighbouringPQEntry.cost = cost
                            neighbouringPQEntry.Distance = Int(distance)
                            neighbouringPQEntry.originVertex = currentCell
                            priorityQueue.removeAll { c in
                                c.vertex.x == neighbouringPQEntry.vertex.x &&  c.vertex.y == neighbouringPQEntry.vertex.y
                            }
                            priorityQueue.append(neighbouringPQEntry)
                        }
                    }
                    neighbourCell.visited = true
                    mazeCells = await updateCellArray(Cell: neighbourCell, Array: mazeCells)
                }
            }
            firstInQueue.vertex.visited = true
            visitedVertices.append(firstInQueue)
            priorityQueue.remove(at: 0)
            priorityQueue.sort { pq1, pq2 in
                pq1.cost <= pq2.cost
            }
        }
    }
    if var goalPQEntry = priorityQueue.first(where: { c in c.vertex.x == Int(endCoor.x) && c.vertex.y == Int(endCoor.y)}) {
        goalPQEntry.vertex.visited = true
        goalPQEntry.vertex.solution = true
        goalVertex = goalPQEntry
        mazeCells = await updateCellArray(Cell: goalPQEntry.vertex, Array: mazeCells)
    }
    
//            visitedNodes.append(firstInQueue)
//            priorityQueue.removeFirst(1)
//            //print(priorityQueue.removeFirst(1))
//            priorityQueue.sort { $0.Cost < $1.Cost }
//            //print("This is priorityQueue: \(priorityQueue)")
//        }
//    }
//    destinationCell = priorityQueue[0]
    return (mazeCells, priorityQueue, visitedVertices, goalVertex)
}


#Preview {
    AStarSolvedMazeView(solutions: .constant([]), priorityQueue: .constant([Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 3, y: 3, up: false, down: true, left: true, right: false, visited: true, solution: false), originVertex: Optional(Pathwise.Cell(x: 2, y: 3, up: false, down: false, left: true, right: true, visited: true, solution: false)), Distance: 4, cost: 13.9), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 10, y: 7, up: false, down: true, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 7, y: 7, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 6, y: 7, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 5, y: 7, up: false, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 5, y: 8, up: true, down: false, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 4, y: 8, up: true, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 5, y: 9, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 6, y: 9, up: true, down: false, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 6, y: 8, up: false, down: true, left: false, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 4, y: 7, up: true, down: true, left: false, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 4, y: 6, up: false, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 5, y: 6, up: true, down: false, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 5, y: 5, up: false, down: true, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 4, y: 5, up: true, down: false, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 4, y: 4, up: true, down: true, left: false, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 4, y: 3, up: false, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 5, y: 3, up: false, down: true, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 5, y: 4, up: true, down: false, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 6, y: 4, up: true, down: false, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 6, y: 3, up: false, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 7, y: 3, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 8, y: 3, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 9, y: 3, up: false, down: true, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 9, y: 4, up: true, down: true, left: false, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 9, y: 5, up: true, down: true, left: false, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 9, y: 6, up: true, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 8, y: 5, up: false, down: true, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 7, y: 5, up: true, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 7, y: 4, up: false, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 8, y: 4, up: false, down: false, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 7, y: 6, up: true, down: false, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 6, y: 6, up: true, down: false, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 6, y: 5, up: false, down: true, left: false, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 10, y: 6, up: true, down: false, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 10, y: 5, up: true, down: true, left: false, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 10, y: 4, up: true, down: true, left: false, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 10, y: 3, up: true, down: true, left: false, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 10, y: 2, up: true, down: true, left: false, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 10, y: 1, up: false, down: true, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 9, y: 1, up: false, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 9, y: 2, up: true, down: false, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 8, y: 2, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 7, y: 2, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 6, y: 2, up: true, down: false, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 6, y: 1, up: false, down: true, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 5, y: 1, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 4, y: 1, up: false, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 4, y: 2, up: true, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 3, y: 2, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 2, y: 2, up: true, down: false, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 2, y: 1, up: false, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 3, y: 1, up: false, down: false, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 5, y: 2, up: false, down: false, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 7, y: 1, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 8, y: 1, up: false, down: false, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 2, y: 10, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 1, y: 10, up: false, down: false, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 2, y: 6, up: false, down: false, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 3, y: 4, up: true, down: false, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 2, y: 4, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 1, y: 4, up: false, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 2, y: 5, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 3, y: 5, up: false, down: true, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 3, y: 6, up: true, down: true, left: false, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 3, y: 7, up: true, down: true, left: false, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 3, y: 8, up: true, down: false, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 2, y: 8, up: true, down: false, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 2, y: 7, up: false, down: true, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 1, y: 8, up: true, down: true, left: false, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 1, y: 9, up: true, down: false, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 2, y: 9, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 3, y: 9, up: false, down: true, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 3, y: 10, up: true, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 5, y: 10, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 6, y: 10, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 7, y: 10, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 8, y: 10, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 9, y: 10, up: true, down: false, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 9, y: 9, up: false, down: true, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 8, y: 9, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 7, y: 9, up: true, down: false, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 7, y: 8, up: false, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 8, y: 8, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 10, y: 8, up: true, down: true, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 10, y: 9, up: true, down: true, left: false, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 10, y: 10, up: true, down: false, left: false, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 4, y: 9, up: true, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 4, y: 10, up: true, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 8, y: 6, up: true, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 8, y: 7, up: true, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 1, y: 5, up: true, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 1, y: 7, up: true, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 1, y: 6, up: true, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 9, y: 8, up: true, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 9, y: 7, up: false, down: true, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000, cost: 2000.0)]), visitedVertices: .constant([Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 1, y: 1, up: false, down: true, left: false, right: false, visited: true, solution: true), originVertex: nil, Distance: 0, cost: 12.73), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 1, y: 2, up: true, down: true, left: false, right: false, visited: true, solution: true), originVertex: Optional(Pathwise.Cell(x: 1, y: 1, up: false, down: true, left: false, right: false, visited: true, solution: false)), Distance: 1, cost: 13.04), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 1, y: 3, up: true, down: false, left: false, right: true, visited: true, solution: true), originVertex: Optional(Pathwise.Cell(x: 1, y: 2, up: true, down: true, left: false, right: false, visited: true, solution: false)), Distance: 2, cost: 13.4), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 2, y: 3, up: false, down: false, left: true, right: true, visited: true, solution: true), originVertex: Optional(Pathwise.Cell(x: 1, y: 3, up: true, down: false, left: false, right: true, visited: true, solution: false)), Distance: 3, cost: 13.63)]), mazeCells: .constant([Pathwise.Cell(x: 10, y: 7, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 7, y: 7, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 7, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 5, y: 7, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 5, y: 8, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 4, y: 8, up: true, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 5, y: 9, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 9, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 6, y: 8, up: false, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 4, y: 7, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 4, y: 6, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 5, y: 6, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 5, y: 5, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 4, y: 5, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 4, y: 4, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 4, y: 3, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 5, y: 3, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 5, y: 4, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 4, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 6, y: 3, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 7, y: 3, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 8, y: 3, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 9, y: 3, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 9, y: 4, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 9, y: 5, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 9, y: 6, up: true, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 8, y: 5, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 7, y: 5, up: true, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 7, y: 4, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 8, y: 4, up: false, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 7, y: 6, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 6, y: 6, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 5, up: false, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 6, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 5, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 4, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 3, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 2, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 1, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 9, y: 1, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 9, y: 2, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 8, y: 2, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 7, y: 2, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 2, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 1, up: false, down: true, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 5, y: 1, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 4, y: 1, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 4, y: 2, up: true, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 3, y: 2, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 2, y: 2, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 2, y: 1, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 3, y: 1, up: false, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 5, y: 2, up: false, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 7, y: 1, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 8, y: 1, up: false, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 2, y: 10, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 1, y: 10, up: false, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 2, y: 6, up: false, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 3, y: 4, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 2, y: 4, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 1, y: 4, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 2, y: 5, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 3, y: 5, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 3, y: 6, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 3, y: 7, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 3, y: 8, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 2, y: 8, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 2, y: 7, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 1, y: 8, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 1, y: 9, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 2, y: 9, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 3, y: 9, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 3, y: 10, up: true, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 5, y: 10, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 10, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 7, y: 10, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 8, y: 10, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 9, y: 10, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 9, y: 9, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 8, y: 9, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 7, y: 9, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 7, y: 8, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 8, y: 8, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 10, y: 8, up: true, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 9, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 10, up: true, down: false, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 4, y: 9, up: true, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 4, y: 10, up: true, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 8, y: 6, up: true, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 8, y: 7, up: true, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 1, y: 5, up: true, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 1, y: 7, up: true, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 1, y: 6, up: true, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 9, y: 8, up: true, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 9, y: 7, up: false, down: true, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 1, y: 1, up: false, down: true, left: false, right: false, visited: true, solution: true), Pathwise.Cell(x: 1, y: 2, up: true, down: true, left: false, right: false, visited: true, solution: true), Pathwise.Cell(x: 1, y: 3, up: true, down: false, left: false, right: true, visited: true, solution: true), Pathwise.Cell(x: 3, y: 3, up: false, down: true, left: true, right: false, visited: true, solution: false), Pathwise.Cell(x: 2, y: 3, up: false, down: false, left: true, right: true, visited: true, solution: true)]), startCoor: .constant(CGPoint(x: 1, y: 1)), endCoor: .constant(CGPoint(x: 10, y: 10)))
}
