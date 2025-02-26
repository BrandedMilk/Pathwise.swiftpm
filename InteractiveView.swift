//
//  InteractiveView.swift
//  Pathwise
//
//  Created by Zhang Hongliang on 20/2/25.
//
import SwiftUI

struct InteractiveView: View {
    @State var numberOfLoops = 4
    @State var currentLoop = 0
    @State var didDismiss = false
    @State var showTaskAlgorithmButton = false
    @Binding var interactiveSideWidth: Double
    @Binding var mazeCells: [Cell]
    @Binding var startCoor: CGPoint
    @Binding var endCoor: CGPoint
    @State var geoSize: CGSize
    @State var checkedPQEntries: [PriorityQEntry] = []
    @Binding var priorityQueue: [PriorityQEntry]
    @State var canReorderPQ = false
    @State var currentPQ: PriorityQEntry = PriorityQEntry(vertex: Cell(x: 1, y: 1), Distance: 0)
    @State var correctPQ: PriorityQEntry = PriorityQEntry(vertex: Cell(x: 1, y: 1), Distance: 0)
    @State private var showAlert = false
    @Binding var solutions: [(Destination: Cell, Origin: Cell?, Distance: CGFloat, Cost: CGFloat)]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color(UIColor.systemGray6))
                    .ignoresSafeArea()
                VStack (alignment: .leading) {
                    Spacer()
                    List {
                        Section {
                            Text(currentLoop == 0 ? "Let's start by selecting the vertex with the lowest distance value." : currentLoop == numberOfLoops ? "Now that you got the hang of it, let's have the device take over." : "Good job, now let's practice a bit more! \(numberOfLoops-currentLoop) more time(s) left.")
                        }
                        Section(header: Text("Priority queue")) {
                            ForEach($priorityQueue, id: \.self) { queueEntry in
                                NavigationLink {
                                    if queueEntry.wrappedValue.vertex == correctPQ.vertex {
                                        DetailedPriorityQView(geoSize: .constant(CGSize(width: geoSize.width*(interactiveSideWidth-0.05), height: geoSize.height*0.95)),mazeCells: $mazeCells, currentPQEntry: queueEntry.wrappedValue, priorityQueue: $priorityQueue, didDismiss: $didDismiss, checkedPQEntries: $checkedPQEntries)
                                            .navigationBarBackButtonHidden(true)
                                    }
                                } label: {
                                    PriorityQueueItemView(queueEntry: queueEntry)
                                }
                                .moveDisabled(!canReorderPQ)
                                .disabled(queueEntry.wrappedValue.vertex != correctPQ.vertex || currentLoop == numberOfLoops)
                                .alert("Whoops! This is not the lowest distance vertex!", isPresented: $showAlert) {
                                    Button("OK", role: .cancel) {showAlert.toggle()}
                                }
                            }.onMove { indices, newOffset in
                                priorityQueue.move(fromOffsets: indices, toOffset: newOffset)
                                //print(priorityQueue)
                            }.onChange(of: didDismiss, { oldValue, newValue in
                                if newValue {
                                    correctPQ = priorityQueue[0]
                                    currentLoop += 1
                                    if currentLoop == numberOfLoops {
//                                        print("Items here:")
//                                        print(priorityQueue)
//                                        print(checkedPQEntries)
//                                        print(mazeCells)
//                                        print(startCoor)
//                                        print(endCoor)
                                        withAnimation {
                                            showTaskAlgorithmButton = true
                                        }
                                    }
                                    print("Current loop is \(currentLoop)")
                                    didDismiss = false
                                }
                            })
                        }
                    }
                    //Load
                    .navigationTitle("A* Algorithm Priority Queue")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbarBackground(Color(UIColor.systemGray6), for: .navigationBar)
                    .scrollContentBackground(.automatic)
//                    .background(RoundedRectangle(cornerRadius: 40))
                    Spacer()
                }
                .frame(width: geoSize.width*(interactiveSideWidth-0.05), height: geoSize.height, alignment: .center)
                if showTaskAlgorithmButton {
                    NavigationLink {
                        AStarSolvedMazeView(solutions: $solutions, priorityQueue: $priorityQueue, visitedVertices: $checkedPQEntries, mazeCells: $mazeCells, startCoor: $startCoor, endCoor: $endCoor)
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        Text("Continue")
                            .frame(width: 210, height: 40, alignment: .center)
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(Color.blue))
                    }.padding(55)
                }
            }
            .frame(width: geoSize.width*interactiveSideWidth, height: geoSize.height, alignment: .leading)
            .padding(.bottom)
        }
        .frame(width: geoSize.width*interactiveSideWidth, height: geoSize.height, alignment: .leading)
        .ignoresSafeArea()
        .onAppear {
            print("InteractiveView is shown again")
            priorityQueue.sort { c1, c2 in
                c1.cost < c2.cost
            }
            print(priorityQueue.isSorted { pq1, pq2 in
                pq1.cost <= pq2.cost
            })
            correctPQ = priorityQueue[0]
        }
    }
}

struct PriorityQueueItemView: View {
    @Binding var queueEntry: PriorityQEntry
    var body: some View {
        HStack(alignment: .center) {
            Text("Cell(X:\(queueEntry.vertex.x),Y:\(queueEntry.vertex.y))")
                .frame(width: 125)
            Divider().frame(width: 1)
            Text(queueEntry.originVertex != nil ? "Path-via: Cell(X:\(queueEntry.originVertex!.x),Y:\(queueEntry.originVertex!.y))" : "Path-via: None")
            Divider().frame(width: 1)
            Text("Distance: \(Int(queueEntry.Distance))")
            Divider().frame(width: 1)
            Text("Cost: \(queueEntry.cost, specifier: "%.2f")")
                .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    InteractiveView(interactiveSideWidth: .constant(0.60), mazeCells: .constant([Pathwise.Cell(x: 9, y: 1, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 10, y: 1, up: false, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 8, y: 5, up: true, down: false, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 7, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 8, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 9, y: 8, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 9, y: 7, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 8, y: 7, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 8, y: 8, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 7, y: 8, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 8, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 9, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 5, y: 10, up: true, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 4, y: 10, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 3, y: 9, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 2, y: 9, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 1, y: 9, up: true, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 1, y: 10, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 2, y: 10, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 3, y: 10, up: false, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 1, y: 8, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 1, y: 7, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 1, y: 6, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 1, y: 5, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 2, y: 4, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 2, y: 3, up: false, down: true, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 1, y: 2, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 2, y: 2, up: false, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 3, y: 4, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 4, y: 4, up: true, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 4, y: 5, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 5, y: 5, up: true, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 5, y: 6, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 6, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 6, y: 7, up: true, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 7, y: 7, up: false, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 5, y: 7, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 5, y: 8, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 4, y: 8, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 4, y: 7, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 4, y: 6, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 3, y: 6, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 2, y: 6, up: true, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 2, y: 5, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 3, y: 5, up: false, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 2, y: 7, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 2, y: 8, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 3, y: 8, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 3, y: 7, up: false, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 5, y: 4, up: false, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 6, y: 10, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 7, y: 10, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 7, y: 9, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 8, y: 9, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 9, y: 9, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 10, y: 9, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 10, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 9, y: 10, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 8, y: 10, up: false, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 2, y: 1, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 3, y: 1, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 3, y: 2, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 4, y: 2, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 4, y: 1, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 1, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 5, y: 3, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 3, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 6, y: 4, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 6, y: 5, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 7, y: 5, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 7, y: 6, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 8, y: 6, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 9, y: 6, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 10, y: 6, up: true, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 5, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 9, y: 5, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 9, y: 4, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 10, y: 4, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 3, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 2, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 9, y: 2, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 9, y: 3, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 8, y: 3, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 8, y: 4, up: true, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 7, y: 4, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 7, y: 3, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 8, y: 2, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 8, y: 1, up: false, down: true, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 7, y: 1, up: false, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 2, up: true, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 7, y: 2, up: false, down: true, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 1, y: 4, up: true, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 1, y: 3, up: true, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 5, y: 2, up: true, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 5, y: 1, up: false, down: true, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 5, y: 9, up: false, down: true, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 4, y: 9, up: false, down: true, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 3, y: 3, up: false, down: true, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 4, y: 3, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 1, y: 1, up: false, down: false, left: false, right: true, visited: true, solution: false)]), startCoor: .constant(CGPoint(x: 1, y: 1)), endCoor: .constant(CGPoint(x: 10, y: 10)), geoSize: CGSize(width: 1080.0, height: 810.0), priorityQueue: .constant([Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 1, y: 1, up: false, down: true, left: false, right: false, visited: true, solution: false), originVertex: nil, Distance: 0, cost: 0 + getEuclideanDistance(current: CGPoint(x: 1, y: 1), end: CGPoint(x: 10, y: 10))), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 2, y: 1, up: false, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 10, y: 10, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 4, y: 1, up: false, down: true, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 4, y: 2, up: true, down: false, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 5, y: 2, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 6, y: 2, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 1000), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 7, y: 2, up: false, down: true, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 7, y: 3, up: true, down: false, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 1000)]), solutions: .constant([]))
}
