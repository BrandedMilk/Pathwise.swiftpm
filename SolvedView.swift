//
//  SolvedView.swift
//  Pathwise
//
//  Created by Zhang Hongliang on 19/2/25.
//
import Foundation
import SwiftUI
import UIKit

struct SolvedView: View {
    @Binding var mazeCells: [Cell]
    @Binding var endCoor: CGPoint
    @Binding var startCoor: CGPoint
    @Binding var userDistance: Int
    @Binding var time: Int
    @Binding var randomness: Int
    @State var aStarDistance: Int = 0
    @State var aStarTime: Double = 0.0
    @State private var showEduView = false
    
    
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
                .ignoresSafeArea()
            VStack {
                Text("Well done! 🎉")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                Text("It took you **\(time) seconds** to solve the maze!")
                    .font(.title)
                Text("While it took the A* algorithm **\(aStarTime, specifier: "%.3f") miliseconds** to solve the maze.")
                    .font(.title)
                Text("The shortest path the A* algorithm has found is **\(aStarDistance) units** long.")
                    .font(.title)
                Text("Whilst your solution is **\(userDistance) units** long.")
                    .font(.title)
                Text(userDistance == aStarDistance ? "Seems like you have found the shortest path in this maze!" : "Seems like there is a shorter path in this maze!")
                    .font(.title)
                Text("So how does A* algorithm find the shortest path quickly?")
                    .font(.title)
                    .padding()
                Button {
                    print("Transition to education view")
                    withAnimation {
                        showEduView.toggle()
                    }
                } label: {
                    Text("Next")
                        .frame(width: 210, height: 50, alignment: .center)
                        .font(.system(size: 30))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(Color.blue))
                        .contentShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                }


            }.padding()
            if showEduView {
                EduView(randomness: $randomness)
                    .transition(.move(edge: .trailing))
            }
        }.onAppear {
            Task {
                let startTime = DispatchTime.now()
                let aStarSolution = await aStarAlgorithm(cells: mazeCells, start: startCoor, end: endCoor)
                let endTime = DispatchTime.now()
                let elapsedTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
                aStarTime = Double(elapsedTime) / 1_000_000
                aStarDistance = Int(aStarSolution.Distance)
            }
        }

    }
}
#Preview {
    SolvedView(mazeCells: .constant([Cell(x: 1, y: 1, up: false, down: false, left: false, right: false, visited: false, solution: false)]), endCoor: .constant(CGPoint(x: 1, y: 1)), startCoor: .constant(CGPoint(x: 10, y: 10)) , userDistance: .constant(0), time: .constant(20), randomness: .constant(5))
}
