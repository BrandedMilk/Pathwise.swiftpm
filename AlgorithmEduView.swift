//
//  AlgorithmEduView.swift
//  Pathwise
//
//  Created by Zhang Hongliang on 20/2/25.
//
import SwiftUI

struct AlgorithmEduView: View {
    @State var mazeCells: [Cell] = []
    @Binding var randomness: Int
    @State var solutions: [(Destination: Cell, Origin: Cell?, Distance: CGFloat, Cost: CGFloat)] = []
    @State var startCoor: CGPoint = CGPoint(x: 1, y: 1)
    @State var endCoor: CGPoint = CGPoint(x: 10, y: 10)
    @State var rectWidth:CGFloat = 500
    // Debugging: set this to true
    @State var showMaze = false
    @State var showInteractiveView = false
    @State var buttonIndex = 0
    @State var priorityQueue: [PriorityQEntry] = []
    @State var interactiveSideWidth = 0.60
    @State var mazeSideWidth = 0.40
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .regular))
                .ignoresSafeArea()
            GeometryReader { geo in
                HStack(alignment: .center){
                    Spacer()
                    ZStack {
                        Rectangle()
                            .frame(width: geo.size.width*mazeSideWidth, height: geo.size.height, alignment: .center)
                            .opacity(0)
                        MazeDrawingView(mazeRandomness: $randomness, rectWidth: $rectWidth, mazeCells: $mazeCells, solutions: $solutions, startCoor: $startCoor, endCoor: $endCoor)
                            .opacity(showMaze ? 1 : 0)
                        MazeOverlayView(mazeCells: $mazeCells, startCoor: $startCoor, endCoor: $endCoor, rectWidth: $rectWidth)
                            .opacity(showMaze ? 1 : 0)
                        
                    }.onAppear {
                        rectWidth = geo.size.width*(mazeSideWidth-0.03)
                    }
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(UIColor.systemGray6))
                            .overlay {
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(Color(UIColor.systemGray4), lineWidth: 2)
                            }
                        VStack(alignment: .leading) {
                            // Need to work on when showMaze is not true: view is a bit messed up
                            Text(showMaze ? "When the algorithm first start, it will have no idea how the cells are connected nor its weights. \n \n Thus, this will be represented by having the maze be covered except for the starting and finish vertex." : "Published in a paper in 1968, A* is an improvement on the first shortest path algorithm call Dijkstra's Algorithm \n In this section, you will take on the role of the A* Algorithm to solve a maze!")
                                .multilineTextAlignment(.leading)
                                .padding()
                                .opacity(showInteractiveView ? 0 : 1)
                            if showMaze {
                                Text("To help the algorithm search through the maze in an efficient manner, it will choose to search a vertex that has the lowest cost value. To accomplish this, all the vertices are sorted by their cost values.")
                                    .multilineTextAlignment(.leading)
                                    .padding()
                                    .opacity(buttonIndex >= 1 ? 1 : 0)
                                    .opacity(showInteractiveView ? 0 : 1)
                                Text("Each vertex in the priority queue will look like this:")
                                    .multilineTextAlignment(.leading)
                                    .padding()
                                    .opacity(buttonIndex >= 2 ? 1 : 0)
                                    .opacity(showInteractiveView ? 0 : 1)
                                HStack {
                                    Spacer()
                                    Text("**Vertex: Cell(X:,Y:)**")
                                    Divider().frame(width: 1)
                                    Text("**Path-via:** \nA vertex that can be 'None' or Cell(X:,Y:)")
                                    Divider().frame(width: 1)
                                    Text("**Distance:** \nThis represents the total distance of all the edges traversed to reach this vertex.")
                                    Divider().frame(width: 1)
                                    Text("**Cost:** \nThis represents the sum of the distance and the straightline distance to the goal.")
                                    Spacer()
                                }
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                                .opacity(buttonIndex >= 2 ? 1 : 0)
                                .opacity(showInteractiveView ? 0 : 1)
                                Text("As the algorithm have no idea how the maze is connected, it will assume that every other vertex is not connected and set a large arbitary distance and cost value to represent this.")
                                    .multilineTextAlignment(.leading)
                                    .padding()
                                    .opacity(buttonIndex >= 3 ? 1 : 0)
                                    .opacity(showInteractiveView ? 0 : 1)
                            }
                            HStack {
                                Spacer()
                                Button {
                                    if !showMaze {
                                        print("Show maze")
                                        mazeCells = mazeCells.map({ c in
                                            var cell = c
                                            if cell.x == Int(startCoor.x) && cell.y == Int(startCoor.y) {
                                                cell.visited = false
                                            } else {
                                                cell.visited = false
                                            }
                                            return cell
                                        })
                                        withAnimation {
                                            showMaze.toggle()
                                        }
                                    } else {
                                        withAnimation {
                                            if buttonIndex != 4 {
                                                buttonIndex += 1
                                                print(buttonIndex)
                                            }
                                            if buttonIndex == 4 {
                                                for cell in mazeCells {
                                                    if cell.x == Int(startCoor.x) && cell.y == Int(startCoor.y){
                                                        let unRoundedcost = 0 + getEuclideanDistance(current: CGPoint(x: cell.x, y: cell.y), end: endCoor)
                                                        let roundedCost = round(unRoundedcost*100)/100.0
                                                        priorityQueue.append(PriorityQEntry(vertex: cell, originVertex: nil, Distance: 0, cost: roundedCost))
                                                    } else {
                                                        let distance = 1000
                                                        priorityQueue.append(PriorityQEntry(vertex: cell, originVertex: nil, Distance: distance, cost: CGFloat(distance+1000)))
                                                    }
                                                }
                                                priorityQueue.sort { c1, c2 in
                                                    c1.cost < c2.cost
                                                }
                                                print(priorityQueue)
                                                showInteractiveView.toggle()
                                                //print(geo.size)
                                            }
                                        }
                                    }
                                } label: {
                                    Text("Next")
                                        .frame(width: 210, height: 50, alignment: .center)
                                        .font(.system(size: 30))
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                        .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(Color.blue))
                                }
                                .padding()
                                .disabled(buttonIndex == 4)
                                .opacity(showInteractiveView ? 0 : 1)
                                Spacer()
                            }

                        }.frame(width: geo.size.width*(interactiveSideWidth-0.05), height: geo.size.height, alignment: .center)
                        if showInteractiveView {
                            InteractiveView(interactiveSideWidth: $interactiveSideWidth, mazeCells: $mazeCells, startCoor: $startCoor, endCoor: $endCoor, geoSize: geo.size, priorityQueue: $priorityQueue, solutions: $solutions)
                                .transition(.move(edge: .trailing))
                        }
                    }.frame(width: geo.size.width*interactiveSideWidth, height: geo.size.height, alignment: .leading)
                    Spacer()
                }
            }
        }.ignoresSafeArea()
        .onAppear {
            Task {
                guard let generatedMaze =  await generateMaze(randomness: randomness) else {
                    print("error in maze generation")
                    return
                }
                mazeCells = generatedMaze
                mazeSideWidth = 1.0-interactiveSideWidth
            }
        }
    }
}

#Preview {
    AlgorithmEduView(randomness: .constant(5))
}
