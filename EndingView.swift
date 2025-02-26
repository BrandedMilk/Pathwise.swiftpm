//
//  EndingView.swift
//  Pathwise
//
//  Created by Zhang Hongliang on 24/2/25.
//
import SwiftUI

struct EndingView: View{
    @State var buttonCounter = 0
    @State var showRestart = false
    var body: some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(Color(UIColor.systemGray6))
                .ignoresSafeArea()
            VStack (alignment: .leading) {
                Spacer()
                Text("I hope you have a better understanding of the inner workings of the A* algorithm!")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding()
                Text("Pathfind algorithms like A* have many real life applications, such as: finding the fastest route in a map, creating a path for NPC/Enemies in games, route traversal for robots or just solving a maze!")
                    .padding()
                    .opacity(buttonCounter >= 1 ? 1 : 0)
                Text("**Thank you** for taking the time to experience learning A* on my application!")
                    .padding()
                    .opacity(buttonCounter >= 2 ? 1 : 0)
                Text("If you want to learn more in-depth about A* Algorithm, these are good reading materials: \n'A Formal Basis for the Heuristic Determination of Minimum Cost Paths.' 1968 By Hart, Peter, Nils Nilsson, and Bertram Raphael \n'A* Heuristic Search tutorial slides' By Andrew W. Moore \n'Admissible heuristic' Engati \n'A* Search Algorithm' Geekforgeek \n'A* search algorithm, Admissible Heuristic, Consistent Heuristic' Wikipedia")
                    .padding()
                    .opacity(buttonCounter >= 3 ? 1 : 0)
                Text("Credits to: Hacking with swift, StackOverflow and Predrag Samardzic's solution to moving the textfield when the keyboard appears.")
                    .padding()
                    .opacity(buttonCounter >= 4 ? 1 : 0)
                Spacer(minLength: 70)
            }
            if !showRestart {
                Button {
                    if buttonCounter != 4 {
                        withAnimation {
                            buttonCounter += 1
                        }
                    }
                } label: {
                    Text(buttonCounter != 4 ? "Next" : "Restart")
                        .frame(width: 210, height: 40, alignment: .center)
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(Color.blue))

                }
                .padding(25)
                .opacity(buttonCounter == 4 ? 0 : 1)
            }
        }
    }
}

#Preview {
    EndingView()
}
