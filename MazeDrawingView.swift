//
//  MazeDrawingView.swift
//  Pathwise
//
//  Created by Zhang Hongliang on 19/2/25.
//

import SwiftUI

struct MazeDrawingView: View {
    @Binding var mazeRandomness: Int
    @Binding var rectWidth: CGFloat
    @Binding var mazeCells: [Cell]
    @Binding var solutions: [(Destination: Cell, Origin: Cell?, Distance: CGFloat, Cost: CGFloat)]
    @Binding var startCoor: CGPoint
    @Binding var endCoor: CGPoint
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(UIColor.systemGray6))
                .frame(width: rectWidth, height: rectWidth)
            Grid(horizontalSpacing: 0, verticalSpacing: 0) {
                ForEach(0..<11, id: \.self) {
                    yAxis in
                    GridRow {
                        ForEach(0..<11, id: \.self) { xAxis in
                            if let cell = mazeCells.first(where: { c in
                                c.x == xAxis && c.y == yAxis
                            }){
                                // Maze Drawing code
                                ZStack {
                                    Path { path in
                                        if !cell.right {
                                            var rightLine = Path()
                                            rightLine.move(to: CGPoint(x: rectWidth/10, y: 0))
                                            rightLine.addLine(to: CGPoint(x: rectWidth/10, y: rectWidth/10))
                                            path.addPath(rightLine)
                                        }
                                        if !cell.down {
                                            var bottomLine = Path()
                                            bottomLine.move(to: CGPoint(x: rectWidth/10, y: rectWidth/10))
                                            bottomLine.addLine(to: CGPoint(x: 0, y: rectWidth/10))
                                            path.addPath(bottomLine)
                                        }
                                        if !cell.left {
                                            var leftLine = Path()
                                            leftLine.move(to: CGPoint(x: 0, y: rectWidth/10))
                                            leftLine.addLine(to: CGPoint(x: 0, y: 0))
                                            path.addPath(leftLine)
                                        }
                                        if !cell.up {
                                            var topLine = Path()
                                            topLine.move(to: CGPoint(x: 0, y: 0))
                                            topLine.addLine(to: CGPoint(x: rectWidth/10, y: 0))
                                            path.addPath(topLine)
                                        }
                                        
                                    }
                                    .stroke(.black, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                                    
                                    //                                            Text("\(getEuclideanDistanceWrong(current: CGPoint(x: cell.x, y: cell.y), end: endCoor))")
                                    //                                                .font(.system( size: 11))
                                    
                                    // Solution Path Code
                                    Path { solutionPath in
                                        if cell.solution {
                                            var solutionLine = Path()
                                            solutionLine.move(to: CGPoint(x: rectWidth/20, y: rectWidth/20))
                                            let direction = getNeighbourSolution(Origin: cell, SolutionTuple: solutions)
                                            // Up
                                            if direction.Up && cell.up && cell.visited{
                                                var upLine = Path()
                                                upLine.move(to: CGPoint(x: rectWidth/20, y: rectWidth/20))
                                                upLine.addLine(to: CGPoint(x: rectWidth/20, y: 0))
                                                solutionLine.addPath(upLine)
                                            }
                                            //Down
                                            if direction.Down && cell.down && cell.visited{
                                                var downLine = Path()
                                                downLine.move(to: CGPoint(x: rectWidth/20, y: rectWidth/20))
                                                downLine.addLine(to: CGPoint(x: rectWidth/20, y: rectWidth/10))
                                                solutionLine.addPath(downLine)
                                            }
                                            //Left
                                            if direction.Left && cell.left && cell.visited{
                                                var leftLine = Path()
                                                leftLine.move(to: CGPoint(x: rectWidth/20, y: rectWidth/20))
                                                leftLine.addLine(to: CGPoint(x: 0, y: rectWidth/20))
                                                solutionLine.addPath(leftLine)
                                            }
                                            //Right
                                            if direction.Right && cell.right && cell.visited{
                                                var rightLine = Path()
                                                rightLine.move(to: CGPoint(x: rectWidth/20, y: rectWidth/20))
                                                rightLine.addLine(to: CGPoint(x: rectWidth/10, y: rectWidth/20))
                                                solutionLine.addPath(rightLine)
                                            }
                                            solutionPath.addPath(solutionLine)
                                        }
                                    }
                                    .stroke(.red, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                                    
                                    
                                    if cell.x == Int(startCoor.x) && cell.y == Int(startCoor.y){
                                        Circle()
                                            .fill(.green)
                                            .frame(width: 10, height: 10)
                                    }
                                    
                                    if cell.x == Int(endCoor.x) && cell.y == Int(endCoor.y){
                                        Circle()
                                            .fill(.red)
                                            .frame(width: 10, height: 10)
                                    }
                                    
                                    
                                }
                                .frame(width: rectWidth/10, height: rectWidth/10)
                            }
                        }
                    }
                }
            }
        }
    }
}
