//
//  DetailedPriorityQ.swift
//  Pathwise
//
//  Created by Zhang Hongliang on 20/2/25.
//

import SwiftUI

struct DetailedPriorityQView: View {
    
    // bug with adapt to keyboard again
    @Environment(\.dismiss) var dismiss
    @Binding var geoSize: CGSize
    @State var updateTrigger = false
    @State var needUpdatePQ: [Bool] = [] //If one/many items is true, show PQ to have user sort then afterwards update isEditDone
    @State var isEditDone: [(vertex: Cell, isDoneEditing: Bool)] = [] //If all is true, then show button to dismiss view; only modified in pq sorting view
    @State var neighbourCells: [Cell] = []
    @State var neighbourPQEntry: [PriorityQEntry] = []
    @State var unModifiedNeighbourPQEntry: [PriorityQEntry] = []
    @Binding var mazeCells: [Cell]
    let currentPQEntry: PriorityQEntry
    @Binding var priorityQueue: [PriorityQEntry]
    @State private var testing = 0
    @State private var pqSortAlert = false
    @State private var showDismissButton = false
    @Binding var didDismiss: Bool
    @Binding var checkedPQEntries: [PriorityQEntry]
    
    
/* In this section: User will:
Find and choose neighbouring vertices (Have to highlight the neighbouring vertices and also unblur them in the MazeDrawingView)
Then investigate the choosen vertex (Done)
Add the total weight of the edge to the total distance of current vertex
Compare this total distance against priorityQ entry for this cell
If the item has lower total distance, like tap a button if this is true (Error catch if user makes a mistake)
Then update the priorityQ entry's for Path-via and total distance.
When done with this neighbour vertex, if theres more, repeat again
then remove the current cell node from pq and put it in another array
 then exit back to interactive experience
 */
    
//Case when checks leads to no changes in PQ order and stuff, will update isEditDone for that cell, then if isEditDone satify all true AND need updatePQ satify all false, then showDismissButton is true
//When implementing the picker, if distance bigger/same, then based on isDoneEditing = true, disable picker but still show conditionally, else, then enable picker, if picker is wrong, show alert and revert to original, else if correct, then append needUpdatePQ AND THEN disable picker
// DO THIS FIRST ^
    
    
    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(Color(UIColor.systemGray6))
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    List {
                        Section(header: Text("Tips")) {
                            Text(needUpdatePQ.contains(true) ? (showDismissButton ? "Now remove the selected vertex: Cell(X:\(currentPQEntry.vertex.x),Y:\(currentPQEntry.vertex.y)) from the priority queue as we have finished investigating it." : "Now, you will sort the edited entry in the priority queue. Hold down on the entry to move it.") :"Here, you will update the neighbouring vertices values. \nNeighbour vertices are connected from the selected vertex by a edge of 1 distance.")
                        }
                        // Then modify this section
                        // .font(.title3).textCase(nil)
                        Section(header: Text("Currently selected vertex: Cell(X:\(currentPQEntry.vertex.x),Y:\(currentPQEntry.vertex.y))")) {
                            HStack {
                                Text("Total distance: \(currentPQEntry.Distance) units")
                                Divider().frame(width: 1)
                                Text("Cost: \(currentPQEntry.cost, specifier: "%.2f")")
                                Divider().frame(width: 1)
                                Text("Cell connected via: \(currentPQEntry.originVertex == nil ? "None" : "Cell(X:\(currentPQEntry.originVertex!.x), Y:\(currentPQEntry.originVertex!.y)")")
                            }
                        }
                        ForEach($neighbourPQEntry, id: \.self) { pqEntry in
                            Section(header: Text("Neighbour vertex: Cell(X:\(pqEntry.wrappedValue.vertex.x),Y:\(pqEntry.wrappedValue.vertex.y))")) {
                                NeighbourCellEditList(needUpdatePQ: $needUpdatePQ, isEditDone: $isEditDone, updateTrigger: $updateTrigger, pqEntry: pqEntry, unModifiedNeighbourPQEntry: $unModifiedNeighbourPQEntry, currentPQEntry: .constant(currentPQEntry), neighbourPQEntry: $neighbourPQEntry, priorityQueue: $priorityQueue)
                                    .onAppear {
                                        print("NeighbourCellEdit list is shown!")
                                        print(currentPQEntry)
                                    }
                            }
                        }
                        // Better way to check if they are sorted is not by moving them physically
                        // Maybe when ever item moves, for each tuple in isDoneEdit, check the tuple's vertex and see if its current location is sorted, then if so change isDoneEditing to true, else isDoneEditing to false, then if satify all items in isDoneEdit is true and also the entire queue is sorted, then so dismiss
                        //ONLY When needUpdatePQ satify all true, then show pq, will toggle updatePQ at the specific index, if no need to update, then just remove value at index
                        if needUpdatePQ.allSatisfy({ $0 == true }) {
                            Section(header: Text("Sort the priority queue by smallest to biggest cost")) {
                                ForEach($priorityQueue, id: \.self) { pqEntry in
                                    PriorityQueueItemView(queueEntry: pqEntry)
                                }.onMove { indices, newOffset in
                                    print("moved pqEntry is: \(priorityQueue[indices.first ?? 3])")
                                    priorityQueue.move(fromOffsets: indices, toOffset: newOffset)
                                    var tupleIndex = 0
                                    for tuple in isEditDone {
                                        if let pqIndex = priorityQueue.firstIndex(where:{ pqEntry in
                                            pqEntry.vertex.x == tuple.vertex.x && pqEntry.vertex.y == tuple.vertex.y
                                       }) {
                                            switch pqIndex {
                                            case 0:
                                                if priorityQueue[pqIndex].cost <= priorityQueue[pqIndex+1].cost {
                                                    var pqTuple = tuple
                                                    isEditDone.remove(at: tupleIndex)
                                                    pqTuple.isDoneEditing = true
                                                    isEditDone.insert(pqTuple, at: tupleIndex)
                                                } else {
                                                    var pqTuple = tuple
                                                    isEditDone.remove(at: tupleIndex)
                                                    pqTuple.isDoneEditing = false
                                                    isEditDone.insert(pqTuple, at: tupleIndex)
                                                }
                                            case priorityQueue.count-1:
                                                if priorityQueue[pqIndex-1].cost <= priorityQueue[pqIndex].cost {
                                                    var pqTuple = tuple
                                                    isEditDone.remove(at: tupleIndex)
                                                    pqTuple.isDoneEditing = true
                                                    isEditDone.insert(pqTuple, at: tupleIndex)
                                                } else {
                                                    var pqTuple = tuple
                                                    isEditDone.remove(at: tupleIndex)
                                                    pqTuple.isDoneEditing = false
                                                    isEditDone.insert(pqTuple, at: tupleIndex)
                                                }
                                            default:
                                                if priorityQueue[pqIndex].cost <= priorityQueue[pqIndex+1].cost && priorityQueue[pqIndex-1].cost <= priorityQueue[pqIndex].cost {
                                                    var pqTuple = tuple
                                                    isEditDone.remove(at: tupleIndex)
                                                    pqTuple.isDoneEditing = true
                                                    isEditDone.insert(pqTuple, at: tupleIndex)
                                                } else {
                                                    var pqTuple = tuple
                                                    isEditDone.remove(at: tupleIndex)
                                                    pqTuple.isDoneEditing = false
                                                    isEditDone.insert(pqTuple, at: tupleIndex)
                                                }
                                            }
                                       }
                                        tupleIndex += 1
                                    }
                                    if isEditDone.allSatisfy({ $0.isDoneEditing == true }) && priorityQueue.isSorted(isOrderedBefore: { pq1, pq2 in
                                        pq1.cost <= pq2.cost
                                    }) {
                                        withAnimation() {
                                            showDismissButton = true
                                        }
                                    }
                                }
                            }
                            .transition(.move(edge: .bottom))
                            .moveDisabled(showDismissButton)
                        }
                    }
                }.adaptsToKeyboard()
                 .frame(width: geoSize.width, alignment: .center)
                if showDismissButton {
                    Button {
                        checkedPQEntries.append(priorityQueue.first(where: { pqEntry in
                            pqEntry.vertex.x == currentPQEntry.vertex.x && pqEntry.vertex.y == currentPQEntry.vertex.y
                        }) ?? PriorityQEntry(vertex: Pathwise.Cell(x: 1, y: 1, up: false, down: true, left: false, right: false, visited: true, solution: false), originVertex: nil, Distance: 0))
                        priorityQueue.removeAll { pqEntry in
                            pqEntry.vertex.x == currentPQEntry.vertex.x && pqEntry.vertex.y == currentPQEntry.vertex.y
                        }
                        didDismiss = true
                        dismiss()
                    } label: {
                        Text("Remove the selected vertex from Priority queue.")
                            .frame(width: 450, height: 35, alignment: .center)
                            .multilineTextAlignment(.center)
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(Color.red))
                    }
                    .padding()
                }
            }
            .onAppear {
                    Task {
                        print("DetailedPriorityQView is showing now")
                        // Update this section with the new functions
                        neighbourCells = await findNeighbouringCells(selectedCell: currentPQEntry.vertex, mazeCells: mazeCells)
                        print("neighbourCells")
                        print(neighbourCells)
                        // Update 3 items, mazeCells, neighbourCells, prirorityQueue
                        for neighbourCell in neighbourCells {
                            var modCell = neighbourCell
                            modCell.visited = true
                            mazeCells = await updateCellArray(Cell: modCell, Array: mazeCells)
                            priorityQueue = await updatePriorityQueue_Cell(newVertex: modCell, priorityQueue: priorityQueue)
                            isEditDone.append((neighbourCell,false))
                            needUpdatePQ.append(false)
                        }
                        var currentSelectedEntry = currentPQEntry
                        currentSelectedEntry.vertex.visited = true
                        mazeCells = await updateCellArray(Cell: currentSelectedEntry.vertex, Array: mazeCells)
                        priorityQueue = await updatePriorityQueue_Cell(newVertex: currentSelectedEntry.vertex, priorityQueue: priorityQueue)
                        priorityQueue.sort { c1, c2 in
                            c1.cost < c2.cost
                        }
                        neighbourCells = neighbourCells.map({ c in
                            var cell = c
                            cell.solution = true
                            cell.visited = true
                            return cell
                        })
                        neighbourPQEntry = await findNeighbourCellPQEntry(neighbourCells: neighbourCells, priorityQueue: priorityQueue)
                        print("neighbourPQEntry")
                        print(neighbourPQEntry)
                        unModifiedNeighbourPQEntry = neighbourPQEntry
                    }
                }
        }.ignoresSafeArea()
    }
}

//struct PrirorityQueueListView: View {
//    @Binding var priorityQueue: [PriorityQEntry]
//    var body: some View {
//        List {
//            ForEach($priorityQueue, id: \.self) { pqEntry in
//                PriorityQueueItemView(queueEntry: pqEntry)
//            }.onMove { indices, newOffset in
//                print(indices)
//                priorityQueue.move(fromOffsets: indices, toOffset: newOffset)
//                print(priorityQueue)
//                if priorityQueue.isSorted(isOrderedBefore: { pq1, pq2 in
//                    pq1.Distance <= pq2.Distance
//                }) {
//                    //Checks if the selected pqEntry to move is that of one of the neighbourCells in the isEditing section
//                    // Will update the according neighbourCell's isDoneEditing Bool that is done editing
//                }
//            }
//        }
//    }
//}

struct CostCheckPQView: View {
    @Binding var isDoneEditing: [(vertex: Cell, isDoneEditing: Bool)]
    @Binding var shouldShowNeighbourPicker: Bool
    @Binding var priorityQueue: [PriorityQEntry]
    @Binding var index: Int
    @Binding var needUpdatePQ: [Bool]
    @Binding var pqEntry: PriorityQEntry
    @Binding var unModifiedNeighbourPQEntry: [PriorityQEntry]
    @State var oldCostValue: CGFloat = 100
    var body: some View {
        HStack {
            Text("Old total cost value: \(unModifiedNeighbourPQEntry[0].cost, specifier: "%.2f")")
            Divider().frame(width: 1)
            Text("New total cost value: \(pqEntry.cost, specifier: "%.2f")")
            Divider().frame(width: 1)
            Text(oldCostValue > pqEntry.cost ? "As the cost is lower, we have found a new shortest path to this vertex! 😄" : "Awww, we have not found a shorter path. 😕")
            if oldCostValue <= pqEntry.cost {
                Text("We will not update any of the values of the vertex.")
            }
        }.onAppear {
            print("CostCheckPQView is trying to show")
            oldCostValue = unModifiedNeighbourPQEntry[index].cost
            if oldCostValue > pqEntry.cost {
                withAnimation {
                    shouldShowNeighbourPicker = true
                }
            } else {
                if !isDoneEditing[index].isDoneEditing {
                    isDoneEditing.removeAll { tuple in
                        tuple.vertex.x == pqEntry.vertex.x && tuple.vertex.y == pqEntry.vertex.y
                    }
                    isDoneEditing.insert((vertex: pqEntry.vertex, isDoneEditing: true), at: index)
                    needUpdatePQ.remove(at: index)
                }
            }
        }
    }
}
//View will be shown after CostCheckPQView is show and trigger stuff, then move the appending stuff from the CostCheckPQView to perform in NeighbourCellPickerView
struct NeighbourCellPickerView: View {
    @State var showPickerAlert = false
    @State var pqEntryOrigin: Cell? = nil
    @Binding var pqEntry: PriorityQEntry
    @Binding var neighbourPQEntry: [PriorityQEntry]
    @Binding var currentPQEntry: PriorityQEntry
    @Binding var unModifiedNeighbourPQEntry: [PriorityQEntry]
    @Binding var index: Int
    @Binding var needUpdatePQ: [Bool]
    @Binding var priorityQueue: [PriorityQEntry]
    
    var body: some View {
        HStack {
            Picker("Vertex is connected via:", selection: $pqEntryOrigin) {
                Text("None").tag(nil as Cell?)
                if let originVertex = pqEntry.originVertex {
                    Text("Cell(X:\(originVertex.x),Y:\(originVertex.y))").tag(originVertex)
                }
                Text("Cell(X:\(currentPQEntry.vertex.x),Y:\(currentPQEntry.vertex.y))").tag(currentPQEntry.vertex)
            }.onChange(of: pqEntryOrigin, {
                if pqEntryOrigin?.x == currentPQEntry.vertex.x && pqEntryOrigin?.y == currentPQEntry.vertex.y {
                    print("CurrentPqEntry in picker")
                    print(currentPQEntry)
                    //Correct entry
                    print("Correct entry picker view")
                    pqEntry.originVertex = pqEntryOrigin
                    priorityQueue.removeAll { pq in
                        pq.vertex.x == pqEntry.vertex.x && pq.vertex.y == pqEntry.vertex.y
                    }
                    print("pqEntry is: \(pqEntry)")
                    priorityQueue.insert(pqEntry, at: 0)
                    withAnimation(.easeOut(duration: 0.5)) {
                        needUpdatePQ[index] = true
                    }
                    // Go update PQ and have them do edit
                } else {
                    //Incorrect entry
                    withAnimation {
                        showPickerAlert.toggle()
                        pqEntryOrigin = unModifiedNeighbourPQEntry[index].originVertex
                    }
                }
            })
            .disabled(needUpdatePQ[index])
            .alert("Whoops! The selected Vertex is not correct! \n Hint: Its the vertex you selected previously (Currently Selected Cell)", isPresented: $showPickerAlert) {
                Button("OK", role: .cancel) {showPickerAlert.toggle()}
            }
        }.onAppear {
            pqEntryOrigin = pqEntry.originVertex
            if needUpdatePQ[index] != true && pqEntryOrigin == currentPQEntry.vertex {
                priorityQueue.removeAll { pq in
                    pq.vertex.x == pqEntry.vertex.x && pq.vertex.y == pqEntry.vertex.y
                }
                print("Updated pqEntry is: \(pqEntry.cost)")
                priorityQueue.insert(pqEntry, at: 0)
                withAnimation(.easeOut(duration: 0.5)) {
                    needUpdatePQ[index] = true
                }
            } else {
                print("Have shown PQ List already!")
            }
        }
    }
}

struct PQDistanceTextFieldView: View {
    @Binding var heuristicValue: CGFloat
    @Binding var updateTrigger: Bool
    @Binding var index: Int
    @Binding var shouldShowHeuristicTextfield: Bool
    @Binding var pqEntry: PriorityQEntry
    @Binding var isDistanceEntryCorrect: Bool
    @State var showDistanceAlert = false
    @Binding var unModifiedNeighbourPQEntry: [PriorityQEntry]
    @Binding var currentPQEntry: PriorityQEntry
    @Binding var neighbourPQEntry: [PriorityQEntry]
    @State private var editedDistance = 100
    
    var body: some View {
        HStack {
            Text("The new total distance to this cell is:")
            TextField("Total distance to this cell is:", value: $editedDistance, format: .number)
                .offset(x: isDistanceEntryCorrect ? 0 : -10)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    if editedDistance != currentPQEntry.Distance+1 {
                        //Wrong entry do this:
                        withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.2, blendDuration: 0.2).repeatCount(2, autoreverses: true)) {
                            isDistanceEntryCorrect = false
                        }
                        showDistanceAlert.toggle()
                        shouldShowHeuristicTextfield = false
                        editedDistance = unModifiedNeighbourPQEntry[index].Distance
                    } else {
                        withAnimation {
                            print("Entry is correct!")
                            isDistanceEntryCorrect = true
                            pqEntry.Distance = editedDistance
                            let unroundedValueNeighbour = getEuclideanDistance(current: CGPoint(x: pqEntry.vertex.x, y: pqEntry.vertex.y), end: CGPoint(x: 10, y: 10))
                            let roundedHeuristicValue = round(Double(unroundedValueNeighbour)*100)
                            print(roundedHeuristicValue)
                            heuristicValue = roundedHeuristicValue/100.0
                            shouldShowHeuristicTextfield = true
                        }
                    }
                }
                .alert("Whoops! The distance value is not correct! \n Hint: Its +1 of the total distance of the currently selected vertex!", isPresented: $showDistanceAlert) {
                    Button("OK", role: .cancel) {showDistanceAlert.toggle()}
                }
                .disabled(shouldShowHeuristicTextfield)
        }.onAppear {
//            print("PQDistanceTextfield is shown! Performing actions")
//            print("Is the set neighbourCell distance correct?")
//            print(pqEntry.Distance == currentPQEntry.Distance+1)
//            print(pqEntry.Distance)
//            print(currentPQEntry.Distance + 1)
//            print(currentPQEntry)
            if pqEntry.Distance == currentPQEntry.Distance+1{
                withAnimation {
                    shouldShowHeuristicTextfield = true
                    let unroundedValueNeighbour = getEuclideanDistance(current: CGPoint(x: pqEntry.vertex.x, y: pqEntry.vertex.y), end: CGPoint(x: 10, y: 10))
                    let roundedHeuristicValue = round(unroundedValueNeighbour*100)/100.0
                    heuristicValue = roundedHeuristicValue
                    editedDistance = currentPQEntry.Distance+1
                }
            } else {
                // Watch out for this if not updated
                shouldShowHeuristicTextfield = false
                editedDistance = unModifiedNeighbourPQEntry[index].Distance
            }
        }
    }
}

struct PQCostTextFieldView: View {
    @Binding var heuristicValue: CGFloat
    @Binding var index: Int
    @Binding var shouldShowCostCompare: Bool
    @Binding var neighbourEntry: PriorityQEntry
    @Binding var isDistanceEntryCorrect: Bool
    @State var isCostEntryCorrect = true
    @State var showDistanceAlert = false
    @Binding var unModifiedNeighbourPQEntry: [PriorityQEntry]
    @Binding var currentPQEntry: PriorityQEntry
    @Binding var neighbourPQEntry: [PriorityQEntry]
    @State private var editedCost = 100.0
    
    var body: some View {
        HStack {
            Text("The new total cost of this cell is:")
            TextField("Total cost to this cell is:", value: $editedCost, format: .number)
                .offset(x: isCostEntryCorrect ? 0 : -10)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    if editedCost != Double(neighbourEntry.Distance)+heuristicValue {
                        //Wrong entry do this:
                        withAnimation(Animation.spring(response: 0.2, dampingFraction: 0.2, blendDuration: 0.2).repeatCount(2, autoreverses: true)) {
                            isCostEntryCorrect = false
                        }
                        showDistanceAlert.toggle()
                        shouldShowCostCompare = false
                        editedCost = unModifiedNeighbourPQEntry[index].cost
                    } else {
                        withAnimation {
                            print("Entry is correct!")
                            isCostEntryCorrect = true
                            neighbourEntry.cost = editedCost
                            shouldShowCostCompare = true
//                            neighbourPQEntry = updatePriorityQueue_PQEntry(priorityQueueEntry: pqEntry, priorityQueue: neighbourPQEntry, Index: index)
//                            updateTrigger.toggle()
//                            shouldShowDistanceCompare = true
//                            print(shouldShowDistanceCompare.description)
                        }
                    }
                }
                .alert("Whoops! The cost value is not correct! \n Hint: Its +\(heuristicValue, specifier: "%.2f") of the total distance of the neighbour vertex!", isPresented: $showDistanceAlert) {
                    Button("OK", role: .cancel) {showDistanceAlert.toggle()}
                }
                .disabled(!isDistanceEntryCorrect)
                .disabled(shouldShowCostCompare)
        }.onAppear {
            print("PQCostTextfield is shown! Performing actions")
            if neighbourEntry.cost == CGFloat(neighbourEntry.Distance)+heuristicValue{
                withAnimation {
                    shouldShowCostCompare = true
                    editedCost = Double(neighbourEntry.Distance)+heuristicValue
                }
            } else {
                // Watch out for this if not updated
                shouldShowCostCompare = false
                editedCost = unModifiedNeighbourPQEntry[index].cost
            }
        }
    }
}



struct NeighbourCellEditList: View {
    @Binding var needUpdatePQ: [Bool]
    @Binding var isEditDone: [(vertex: Cell, isDoneEditing: Bool)]
    @Binding var updateTrigger: Bool
    @State var heuristicValue: CGFloat = 0.0
    @State var index: Int = 0
    @State var shouldShowNeighbourPicker = false
    @State var shouldShowHeuristicTextfield: Bool = false
    @State var shouldShowCostCompare: Bool = false
    @Binding var pqEntry: PriorityQEntry
    //Will use to disable cost textfield if distance is modified and is now wrong so nothing get fcked
    @State var isDistanceEntryCorrect = true
    @Binding var unModifiedNeighbourPQEntry: [PriorityQEntry]
    @Binding var currentPQEntry: PriorityQEntry
    @Binding var neighbourPQEntry: [PriorityQEntry]
    @Binding var priorityQueue: [PriorityQEntry]
    
    var body: some View {
        PQDistanceTextFieldView(heuristicValue: $heuristicValue, updateTrigger: $updateTrigger, index: $index, shouldShowHeuristicTextfield: $shouldShowHeuristicTextfield, pqEntry: $pqEntry, isDistanceEntryCorrect: $isDistanceEntryCorrect, unModifiedNeighbourPQEntry: $unModifiedNeighbourPQEntry, currentPQEntry: $currentPQEntry, neighbourPQEntry: $neighbourPQEntry)
            .onAppear {
                index = neighbourPQEntry.firstIndex(where: { pq in
                    pq.vertex.x == pqEntry.vertex.x && pq.vertex.y == pqEntry.vertex.y
                }) ?? 0
        }
        if shouldShowHeuristicTextfield {
            Text("The straightline distance is: \(heuristicValue, specifier: "%.2f")")
            Text("Cost = total distance + straightline distance")
            PQCostTextFieldView(heuristicValue: $heuristicValue, index: $index, shouldShowCostCompare: $shouldShowCostCompare, neighbourEntry: $pqEntry, isDistanceEntryCorrect: $isDistanceEntryCorrect, unModifiedNeighbourPQEntry: $unModifiedNeighbourPQEntry, currentPQEntry: $currentPQEntry, neighbourPQEntry: $neighbourPQEntry)
        }
        if shouldShowCostCompare {
            CostCheckPQView(isDoneEditing: $isEditDone, shouldShowNeighbourPicker: $shouldShowNeighbourPicker, priorityQueue: $priorityQueue, index: $index, needUpdatePQ: $needUpdatePQ, pqEntry: $pqEntry, unModifiedNeighbourPQEntry: $unModifiedNeighbourPQEntry)
        }
        if shouldShowNeighbourPicker {
            NeighbourCellPickerView(pqEntry: $pqEntry, neighbourPQEntry: $neighbourPQEntry, currentPQEntry: $currentPQEntry, unModifiedNeighbourPQEntry: $unModifiedNeighbourPQEntry, index: $index, needUpdatePQ: $needUpdatePQ, priorityQueue: $priorityQueue)
        }
    }
}


#Preview {
    DetailedPriorityQView(geoSize: .constant(CGSize(width: 1080.0*0.60, height: 810*0.95)), mazeCells: .constant([Pathwise.Cell(x: 9, y: 1, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 10, y: 1, up: false, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 8, y: 5, up: true, down: false, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 7, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 8, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 9, y: 8, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 9, y: 7, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 8, y: 7, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 8, y: 8, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 7, y: 8, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 8, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 9, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 5, y: 10, up: true, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 4, y: 10, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 3, y: 9, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 2, y: 9, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 1, y: 9, up: true, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 1, y: 10, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 2, y: 10, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 3, y: 10, up: false, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 1, y: 8, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 1, y: 7, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 1, y: 6, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 1, y: 5, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 2, y: 4, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 2, y: 3, up: false, down: true, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 1, y: 2, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 2, y: 2, up: false, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 3, y: 4, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 4, y: 4, up: true, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 4, y: 5, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 5, y: 5, up: true, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 5, y: 6, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 6, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 6, y: 7, up: true, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 7, y: 7, up: false, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 5, y: 7, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 5, y: 8, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 4, y: 8, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 4, y: 7, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 4, y: 6, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 3, y: 6, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 2, y: 6, up: true, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 2, y: 5, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 3, y: 5, up: false, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 2, y: 7, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 2, y: 8, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 3, y: 8, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 3, y: 7, up: false, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 5, y: 4, up: false, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 6, y: 10, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 7, y: 10, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 7, y: 9, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 8, y: 9, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 9, y: 9, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 10, y: 9, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 10, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 9, y: 10, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 8, y: 10, up: false, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 2, y: 1, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 3, y: 1, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 3, y: 2, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 4, y: 2, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 4, y: 1, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 1, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 5, y: 3, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 3, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 6, y: 4, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 6, y: 5, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 7, y: 5, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 7, y: 6, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 8, y: 6, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 9, y: 6, up: false, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 10, y: 6, up: true, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 5, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 9, y: 5, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 9, y: 4, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 10, y: 4, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 3, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 10, y: 2, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 9, y: 2, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 9, y: 3, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 8, y: 3, up: false, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 8, y: 4, up: true, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 7, y: 4, up: true, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 7, y: 3, up: true, down: true, left: false, right: false, visited: false, solution: false), Pathwise.Cell(x: 8, y: 2, up: true, down: false, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 8, y: 1, up: false, down: true, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 7, y: 1, up: false, down: false, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 6, y: 2, up: true, down: false, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 7, y: 2, up: false, down: true, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 1, y: 4, up: true, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 1, y: 3, up: true, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 5, y: 2, up: true, down: true, left: false, right: true, visited: false, solution: false), Pathwise.Cell(x: 5, y: 1, up: false, down: true, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 5, y: 9, up: false, down: true, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 4, y: 9, up: false, down: true, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 3, y: 3, up: false, down: true, left: true, right: true, visited: false, solution: false), Pathwise.Cell(x: 4, y: 3, up: false, down: true, left: true, right: false, visited: false, solution: false), Pathwise.Cell(x: 1, y: 1, up: false, down: false, left: false, right: true, visited: true, solution: false)]), currentPQEntry: PriorityQEntry(vertex: Cell(x: 1, y: 1, up: false, down: false, left: false, right: true, visited: true, solution: false), Distance: 0), priorityQueue: .constant([Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 1, y: 1, up: false, down: true, left: false, right: false, visited: true, solution: false), originVertex: nil, Distance: 0), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 2, y: 1, up: false, down: true, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 10000), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 3, y: 1, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 10000), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 4, y: 1, up: false, down: true, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 10000), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 4, y: 2, up: true, down: false, left: false, right: true, visited: false, solution: false), originVertex: nil, Distance: 10000), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 5, y: 2, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 10000), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 6, y: 2, up: false, down: false, left: true, right: true, visited: false, solution: false), originVertex: nil, Distance: 10000), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 7, y: 2, up: false, down: true, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 10000), Pathwise.PriorityQEntry(vertex: Pathwise.Cell(x: 7, y: 3, up: true, down: false, left: true, right: false, visited: false, solution: false), originVertex: nil, Distance: 10000)]), didDismiss: .constant(false), checkedPQEntries: .constant([]))
}

// Previous Attempt at checking pqOrder
//                                    let entry = priorityQueue[indices.first ?? 3]
//                                    if let tuple = isEditDone.first(where: { tuple in
//                                        tuple.vertex.x == entry.vertex.x && tuple.vertex.y == entry.vertex.y
//                                    }) {
//                                        // If true, the moved entry is one of the neighbourCells
//
//                                        // This if statement currently check everything is sorted, not correct, should instead check the surrounding vertex distance value, if it is correct then it will be good, do the other shit
//                                        if let index = priorityQueue.firstIndex(where: { pqEntry in
//                                            pqEntry.vertex.x == entry.vertex.x && pqEntry.vertex.y == entry.vertex.y
//                                        }) {
//
//                                            //Cases: When index = 0, when index = 99, everything else
//                                            if index == 0 {
//                                                if priorityQueue[index].cost <= priorityQueue[index+1].cost {
//                                                    //Sorted
//                                                    var pqTuple = tuple
//                                                    isEditDone.removeAll { tuple in
//                                                        tuple.vertex.x == entry.vertex.x && tuple.vertex.y == entry.vertex.y
//                                                    }
//                                                    pqTuple.isDoneEditing = true
//                                                    isEditDone.append(pqTuple)
//                                                    if isEditDone.allSatisfy({ $0.isDoneEditing == true }) && priorityQueue.isSorted(isOrderedBefore: { pq1, pq2 in
//                                                        pq1.cost <= pq2.cost
//                                                    }) {
//                                                        withAnimation() {
//                                                            showDismissButton = true
//                                                        }
//                                                    }
//                                                } else {
//                                                    //Not Sorted
//                                                    var pqTuple = tuple
//                                                    isEditDone.removeAll { tuple in
//                                                        tuple.vertex.x == entry.vertex.x && tuple.vertex.y == entry.vertex.y
//                                                    }
//                                                    pqTuple.isDoneEditing = false
//                                                    isEditDone.append(pqTuple)
//                                                    withAnimation() {
//                                                        showDismissButton = false
//                                                        pqSortAlert.toggle()
//                                                    }
//                                                }
//                                            } else if index == priorityQueue.count-1 {
//                                                if priorityQueue[index-1].cost <= priorityQueue[index].cost {
//                                                    //Sorted
//                                                    var pqTuple = tuple
//                                                    isEditDone.removeAll { tuple in
//                                                        tuple.vertex.x == entry.vertex.x && tuple.vertex.y == entry.vertex.y
//                                                    }
//                                                    pqTuple.isDoneEditing = true
//                                                    isEditDone.append(pqTuple)
//                                                    if isEditDone.allSatisfy({ $0.isDoneEditing == true }) && priorityQueue.isSorted(isOrderedBefore: { pq1, pq2 in
//                                                        pq1.cost <= pq2.cost
//                                                    }) {
//                                                        withAnimation() {
//                                                            showDismissButton = true
//                                                        }
//                                                    }
//                                                } else {
//                                                    //Not Sorted
//                                                    var pqTuple = tuple
//                                                    isEditDone.removeAll { tuple in
//                                                        tuple.vertex.x == entry.vertex.x && tuple.vertex.y == entry.vertex.y
//                                                    }
//                                                    pqTuple.isDoneEditing = false
//                                                    isEditDone.append(pqTuple)
//                                                    withAnimation() {
//                                                        showDismissButton = false
//                                                        pqSortAlert.toggle()
//                                                    }
//                                                }
//                                            } else {
//                                                //All the other possibilities
//                                                if priorityQueue[index].cost <= priorityQueue[index+1].cost && priorityQueue[index-1].cost <= priorityQueue[index].cost{
//                                                    //Sorted
//                                                    var pqTuple = tuple
//                                                    isEditDone.removeAll { tuple in
//                                                        tuple.vertex.x == entry.vertex.x && tuple.vertex.y == entry.vertex.y
//                                                    }
//                                                    pqTuple.isDoneEditing = true
//                                                    isEditDone.append(pqTuple)
//                                                    if isEditDone.allSatisfy({ $0.isDoneEditing == true }) && priorityQueue.isSorted(isOrderedBefore: { pq1, pq2 in
//                                                        pq1.cost <= pq2.cost
//                                                    }) {
//                                                        withAnimation() {
//                                                            showDismissButton = true
//                                                        }
//                                                    }
//                                                } else {
//                                                    //Not Sorted
//                                                    var pqTuple = tuple
//                                                    isEditDone.removeAll { tuple in
//                                                        tuple.vertex.x == entry.vertex.x && tuple.vertex.y == entry.vertex.y
//                                                    }
//                                                    pqTuple.isDoneEditing = false
//                                                    isEditDone.append(pqTuple)
//                                                    withAnimation() {
//                                                        showDismissButton = false
//                                                        pqSortAlert.toggle()
//                                                    }
//                                                }
//                                            }
//                                        }
//                                            //Checks if the selected pqEntry to move is that of one of the neighbourCells in the isEditing section
//                                            // Will update the according neighbourCell's isDoneEditing Bool that is done editing
//                                            //What if the user decides the move the neighbourEntry again to the wrong place?
//                                            //Will just keep updating the array to make the particular value false
//                                    } else {
//                                        // Else, the moved entry is a random cell, bad user
//                                        // This check for other items(not neighbourCells) if user moves them and they are not correct
//
//                                        //If the user moves a non-neighbourCells and its sorted, then show dismiss/retain
//                                        //But could move the
//                                        if isEditDone.allSatisfy({ $0.isDoneEditing == true }) && priorityQueue.isSorted(isOrderedBefore: { pq1, pq2 in
//                                            pq1.cost <= pq2.cost
//                                        }) {
//                                            withAnimation() {
//                                                showDismissButton = true
//                                            }
//                                            // If neighbourCell is sorted, but random cell is not, then do this
//                                        } else if !(priorityQueue.isSorted(isOrderedBefore: { pq1, pq2 in
//                                            pq1.cost <= pq2.cost
//                                        })) {
//                                            pqSortAlert.toggle()
//                                        }
//                                    }
