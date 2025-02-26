import SwiftUI

struct MazeView: View {

    @State var mazeCells: [Cell] = []
    @State var unModifiedMazeCells: [Cell] = []
    @State var totalDistance: Int?
    // Contains tuples that is part of the solution
    @State var solutions: [(Destination: Cell, Origin: Cell?, Distance: CGFloat, Cost: CGFloat)] = []
    @State var startCoor: CGPoint = CGPoint(x: 1, y: 1)
    @State var endCoor: CGPoint = CGPoint(x: 10, y: 10)
    @State var rectWidth:CGFloat = 500
    @State var mazeRandomness = 10
    @State var currentCell = Cell(x: 1, y: 1, up: false, down: false, left: false, right: false, visited: false, solution: false)
    @State var startMazeButton = true
    @State var time = 0
    @State var timerStop = false
    @State var userDistance = 0
    @State var aStarDistance = 0
    @State private var showFinish = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(UIColor.systemGray6))
                .ignoresSafeArea()
            HStack(alignment: .center) {
                Spacer()
// MARK: - Maze code
                MazeDrawingView(mazeRandomness: $mazeRandomness, rectWidth: $rectWidth, mazeCells: $mazeCells, solutions: $solutions, startCoor: $startCoor, endCoor: $endCoor)
                Spacer()
// MARK: - Others
                VStack {
                    
                    Spacer()
                    Text("Let's first try solving this maze!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()
                    Text("You start at the green dot and end on the red dot.")
                        .padding()
                    Text("Your time is: \(time) seconds")
                        .onReceive(timer) { t in
                            if !timerStop {
                                time += 1
                            }
                        }
                        .opacity(startMazeButton ? 0 : 1)
                    //Text("\(currentCell)")
                    Spacer()
// Start Maze Solving Button
                    Button {
                        Task {
                            currentCell = mazeCells.first(where: { c in
                                c.x == 1 && c.y == 1
                            })!
                            currentCell.solution = true
                            mazeCells = mazeCells.map({ c in
                                var cell = c
                                cell.visited = false
                                return cell
                            })
                            mazeCells = await updateCellArray(Cell: currentCell, Array: mazeCells)
                            print(mazeCells)
                            solutions.append((Destination: currentCell, Origin: nil, Distance: 0, Cost: 0))
                            startMazeButton = false
                            time = 0
                        }
                    } label: {
                        Text("Let's start!")
                            .font(.system(size: 35))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(Color.blue).frame(width: 210, height: 55, alignment: .center))
                    }
                    .disabled(!startMazeButton)
                    .opacity(startMazeButton ? 1 : 0)
                    Spacer()
                    HStack {
                        
/* When pressing a button, what will happen?
 Button will check if the cell is connected in that direction
 if it is connected in that direction, it will find the neighbouring cell, make its solution value true, then it will trigger the solution path algorithm to display the new solution path.
 
 Have to add a check if the current cell being moved to is already part of the solution (Means the person is backtracking), if so, then make the current cell no longer the solution and have it be drawn.
 
 Need to add a if statment if the next cell selected in the finish cell, then do something
 */
                        
// MARK: Left button
                        Button {
                            print("Left Button")
                            if currentCell.visited == false {
                                currentCell.visited = true
                                Task {
                                    mazeCells = await updateCellArray(Cell: currentCell, Array: mazeCells)
                                }
                            }
                            if currentCell.left {
                                if var nextCell = mazeCells.first(where: { c in
                                    c.x == currentCell.x-1 && c.y == currentCell.y
                                }){
                                    switch nextCell.solution {
                                    case false:
                                        nextCell.solution = true
                                        nextCell.visited = true
                                        if let currentCellTuple = solutions.first(where: { t in
                                            t.Destination.x == currentCell.x && t.Destination.y == currentCell.y
                                        }) {
                                            solutions.append((nextCell, currentCell, currentCellTuple.Distance+1, 0))
                                        }
                                        if nextCell.x == Int(endCoor.x) && nextCell.y == Int(endCoor.y) {
                                            print("Reached the end")
                                            timerStop = true
                                            withAnimation {
                                                showFinish.toggle()
                                            }
                                            if let endTuple = solutions.last {
                                                print(endTuple.Distance)
                                                userDistance = Int(endTuple.Distance)
                                            }

                                        }
                                        
                                    case true:
                                        if let latestTuple = solutions.last {
                                            let latestCell = latestTuple.Destination
                                            if latestCell.x == currentCell.x && latestCell.y == currentCell.y {
                                                currentCell.solution = false
                                                currentCell.visited = false
                                                Task {
                                                    mazeCells = await updateCellArray(Cell: currentCell, Array: mazeCells)
                                                }
                                                solutions.removeAll { t in
                                                    t.Destination.x == currentCell.x && t.Destination.y == currentCell.y
                                                }
                                            } else {
                                                print("Not backtracking, trying to loop")
                                            }
                                        }

                                    }
                                    Task {
                                        mazeCells = await updateCellArray(Cell: nextCell, Array: mazeCells)
                                    }
                                    currentCell = nextCell
                                    print(currentCell)
                                } else {
                                    print("no cell exists")
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.left")
                                .frame(width: 80, height: 80, alignment: .center)
                                .font(.system(size: 70))
                                .foregroundStyle(.black)
                                .background(in: RoundedRectangle(cornerRadius: 15))
                        }
                        .disabled(startMazeButton)
                        .disabled(timerStop)
                        .opacity(startMazeButton ? 0 : 1)
//Button Stack
                        VStack {
// MARK: Up button
                            Button {
                                print("Up Button")
                                if currentCell.visited == false {
                                    currentCell.visited = true
                                    Task {
                                        mazeCells = await updateCellArray(Cell: currentCell, Array: mazeCells)
                                    }
                                }
                                if currentCell.up {
                                    if var nextCell = mazeCells.first(where: { c in
                                        c.x == currentCell.x && c.y == currentCell.y-1
                                    }) {
                                        switch nextCell.solution {
                                        case false:
                                            nextCell.solution = true
                                            nextCell.visited = true
                                            if let currentCellTuple = solutions.first(where: { t in
                                                t.Destination.x == currentCell.x && t.Destination.y == currentCell.y
                                            }) {
                                                solutions.append((nextCell, currentCell, currentCellTuple.Distance+1, 0))
                                            }
                                            if nextCell.x == Int(endCoor.x) && nextCell.y == Int(endCoor.y) {
                                                print("Reached the end")
                                                timerStop = true
                                                withAnimation {
                                                    showFinish.toggle()
                                                }
                                                if let endTuple = solutions.last {
                                                    print(endTuple.Distance)
                                                    userDistance = Int(endTuple.Distance)
                                                }
                                            }
                                            
                                        case true:
                                            if let latestTuple = solutions.last {
                                                let latestCell = latestTuple.Destination
                                                if latestCell.x == currentCell.x && latestCell.y == currentCell.y {
                                                    currentCell.solution = false
                                                    currentCell.visited = false
                                                    Task {
                                                        mazeCells = await updateCellArray(Cell: currentCell, Array: mazeCells)
                                                    }
                                                    solutions.removeAll { t in
                                                        t.Destination.x == currentCell.x && t.Destination.y == currentCell.y
                                                    }
                                                } else {
                                                    print("Not backtracking, trying to loop")
                                                }
                                            }
                                        }
                                        Task {
                                            mazeCells = await updateCellArray(Cell: nextCell, Array: mazeCells)
                                        }
                                        currentCell = nextCell
                                        print(currentCell)
                                    } else {
                                        print("no cell exists")
                                    }

                                }
                            } label: {
                                Image(systemName: "arrow.up")
                                    .frame(width: 80, height: 80, alignment: .center)
                                    .font(.system(size: 70))
                                    .foregroundStyle(.black)
                                    .background(in: RoundedRectangle(cornerRadius: 15))
                            }
                            .disabled(startMazeButton)
                            .disabled(timerStop)
                            .opacity(startMazeButton ? 0 : 1)
                            
// MARK: Down button
                            Button {
                                print("Down Button")
                                if currentCell.visited == false {
                                    currentCell.visited = true
                                    Task {
                                        mazeCells = await updateCellArray(Cell: currentCell, Array: mazeCells)
                                    }
                                }
                                if currentCell.down {
                                    if var nextCell = mazeCells.first(where: { c in
                                        c.x == currentCell.x && c.y == currentCell.y+1
                                    }) {
                                        switch nextCell.solution {
                                        case false:
                                            nextCell.solution = true
                                            nextCell.visited = true
                                            if let currentCellTuple = solutions.first(where: { t in
                                                t.Destination.x == currentCell.x && t.Destination.y == currentCell.y
                                            }) {
                                                solutions.append((nextCell, currentCell, currentCellTuple.Distance+1, 0))
                                            }
                                            if nextCell.x == Int(endCoor.x) && nextCell.y == Int(endCoor.y) {
                                                print("Reached the end")
                                                timerStop = true
                                                withAnimation {
                                                    showFinish.toggle()
                                                }
                                                if let endTuple = solutions.last {
                                                    print(endTuple.Distance)
                                                    userDistance = Int(endTuple.Distance)
                                                }

                                            }
                                            
                                        case true:
                                            //Ensure that it is actually backtracking and not looping into itself
                                            //Check if the last item of the array is the nextCell
                                            if let latestTuple = solutions.last {
                                                let latestCell = latestTuple.Destination
                                                if latestCell.x == currentCell.x && latestCell.y == currentCell.y {
                                                    currentCell.solution = false
                                                    currentCell.visited = false
                                                    Task {
                                                        mazeCells = await updateCellArray(Cell: currentCell, Array: mazeCells)
                                                    }
                                                    solutions.removeAll { t in
                                                        t.Destination.x == currentCell.x && t.Destination.y == currentCell.y
                                                    }
                                                } else {
                                                    print("Not backtracking, trying to loop")
                                                }
                                            }
                                        }
                                        Task {
                                            mazeCells = await updateCellArray(Cell: nextCell, Array: mazeCells)
                                        }
                                        currentCell = nextCell
                                        print(currentCell)
                                    } else {
                                        print("no cell exists")
                                    }
                                }
                            } label: {
                                Image(systemName: "arrow.down")
                                    .frame(width: 80, height: 80, alignment: .center)
                                    .font(.system(size: 70))
                                    .foregroundStyle(.black)
                                    .background(in: RoundedRectangle(cornerRadius: 15))
                            }
                            .disabled(startMazeButton)
                            .disabled(timerStop)
                            .opacity(startMazeButton ? 0 : 1)
                        }
                        
// MARK: Right button
                        Button {
                            print("Right Button")
                            if currentCell.visited == false {
                                currentCell.visited = true
                                Task {
                                    mazeCells = await updateCellArray(Cell: currentCell, Array: mazeCells)
                                }
                            }
                            if currentCell.right {
                                if var nextCell = mazeCells.first(where: { c in
                                    c.x == currentCell.x+1 && c.y == currentCell.y
                                }) {
                                    switch nextCell.solution {
                                    case false:
                                        nextCell.solution = true
                                        nextCell.visited = true
                                        if let currentCellTuple = solutions.first(where: { t in
                                            t.Destination.x == currentCell.x && t.Destination.y == currentCell.y
                                        }) {
                                            solutions.append((nextCell, currentCell, currentCellTuple.Distance+1, 0))
                                        }
                                        if nextCell.x == Int(endCoor.x) && nextCell.y == Int(endCoor.y) {
                                            print("Reached the end")
                                            timerStop = true
                                            withAnimation {
                                                showFinish.toggle()
                                            }
                                            if let endTuple = solutions.last {
                                                print(endTuple.Distance)
                                                userDistance = Int(endTuple.Distance)
                                            }

                                        }
                                        
                                    case true:
                                        if let latestTuple = solutions.last {
                                            let latestCell = latestTuple.Destination
                                            if latestCell.x == currentCell.x && latestCell.y == currentCell.y {
                                                currentCell.solution = false
                                                currentCell.visited = false
                                                Task {
                                                    mazeCells = await updateCellArray(Cell: currentCell, Array: mazeCells)
                                                }
                                                solutions.removeAll { t in
                                                    t.Destination.x == currentCell.x && t.Destination.y == currentCell.y
                                                }
                                            } else {
                                                print("Not backtracking, trying to loop")
                                            }
                                        }
                                    }
                                    Task {
                                        mazeCells = await updateCellArray(Cell: nextCell, Array: mazeCells)
                                    }
                                    currentCell = nextCell
                                    print(currentCell)
                                } else {
                                    print("no cell exists")
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.right")
                                .frame(width: 80, height: 80, alignment: .center)
                                .font(.system(size: 70))
                                .foregroundStyle(.black)
                                .background(in: RoundedRectangle(cornerRadius: 15))
                        }
                        .disabled(startMazeButton)
                        .disabled(timerStop)
                        .opacity(startMazeButton ? 0 : 1)
                    }
                    
                    Spacer()

//                    Button(action: {
//                        print("I will solve this maze!")
//                        let solution = aStarAlgorithm(cells: mazeCells, start: startCoor, end: endCoor)
//                        mazeCells = solution.Solution
//                        totalDistance = Int(solution.Distance)
//                        solutions = solution.SolutionTuple
//                        print(mazeCells)
//                    }, label: {
//                        ZStack {
//                            RoundedRectangle(cornerSize: CGSize(width: 8, height: 8))
//                                .fill(.black)
//                                .frame(width: 100,height: 40)
//                            Text("Solve")
//                                .fontWeight(.heavy)
//                                .foregroundStyle(.green)
//                            
//                        }
//                    })
                }
                Spacer()
            }
            if showFinish {
                // Need add parameters here
                SolvedView(mazeCells: $unModifiedMazeCells, endCoor: $endCoor, startCoor: $startCoor, userDistance: $userDistance, time: $time, randomness: $mazeRandomness)
                    .transition(.move(edge: .bottom))
            }
        }.onAppear {
            Task {
                if let cellArray = await generateMaze(randomness: mazeRandomness) {
                    mazeCells = cellArray
                    unModifiedMazeCells = cellArray
                } else {
                    print("Maze generation error!")
                }
            }
        }
    }
    
    func forceUpdateMazeCellArray(ArrayToBeUpdated: [Cell]) {
        mazeCells = ArrayToBeUpdated
        print(mazeCells)
    }
}

#Preview {
    MazeView()
}

//func getEuclideanDistanceWrong(current: CGPoint, end: CGPoint) -> Int {
//    let xDistance = abs(current.x - end.x)
//    let yDistance = abs(current.y - end.y)
//    let euclideanDistance = Int(sqrt(xDistance*xDistance + yDistance*yDistance))
//    return euclideanDistance
//}
