//
//  EduView.swift
//  Pathwise
//
//  Created by Zhang Hongliang on 19/2/25.
//
import SwiftUI

struct EduView: View {
    @State var buttonCounter = 0
    @State var explainConcepts = false
    @State var explainHeuristics = false
    @State private var showAlgorithmView = false
    @Binding var randomness: Int
    
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .regular))
                .ignoresSafeArea()
            VStack(alignment: .leading) {
                Text(explainConcepts ? (explainHeuristics ? "Heuristics! What are they? 🔎" : "Some basic concepts of Graph Theory! 💡") : "First, let's understand what is an algorithm? 📝")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.leading, 20)
                    .padding()
                if explainConcepts && !explainHeuristics {
                    //Explain Graph Theory
                    Text("Graph theory is the mathematical study of graphs; where a graph is composed of a set of points connected by a set of lines!")
                        .font(.title3)
                        .multilineTextAlignment(.leading)
                        .opacity(buttonCounter >= 1 ? 1 : 0)
                        .padding(.leading, 20)
                        .padding()
                    Text("**Vertex/Vertices** \n A point on a graph is called a vertex. In the maze a vertex is one cell, thus a 10x10 maze contains 100 cells.")
                        .font(.title3)
                        .multilineTextAlignment(.leading)
                        .opacity(buttonCounter >= 2 ? 1 : 0)
                        .padding(.leading, 20)
                        .padding()
                    Text("**Edge/Edges** \n A line connecting 2 points on a graph is called an edge. In the maze, if 2 cells are not seperated by a wall, they are connected by an edge!")
                        .font(.title3)
                        .multilineTextAlignment(.leading)
                        .opacity(buttonCounter >= 3 ? 1 : 0)
                        .padding(.leading, 20)
                        .padding()
                    Text("**Path** \n It is a collection of vertices and edges that represents the path to reaching a vertex. Thus a Path-via vertex represents the previous vertex that connects to a vertex in a path.")
                        .font(.title3)
                        .multilineTextAlignment(.leading)
                        .opacity(buttonCounter >= 4 ? 1 : 0)
                        .padding(.leading, 20)
                        .padding()
                    Text("**Weight** \n It is a property of an edge, representing a metric like distance, cost or time. \n In the maze, each edge will have a weight of 1 unit distance. Subsequently, weight will be called distance. \n Thus, a maze is a large graph with edges with a weight of 1.")
                        .font(.title3)
                        .multilineTextAlignment(.leading)
                        .opacity(buttonCounter >= 5 ? 1 : 0)
                        .padding(.leading, 20)
                        .padding()
                    Text("With the basics covered, let's learn about what makes A* so unique as a Pathfinding algorithm!")
                        .font(.title3)
                        .opacity(buttonCounter >= 6 ? 1 : 0)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 20)
                        .padding()
                } else if !explainConcepts && !explainHeuristics {
                    //Explain algorithm
                    Text("An algorithm is a set of instructions that is used to solve a problem or accomplish a task.")
                        .font(.title3)
                        .padding()
                        .opacity(buttonCounter >= 1 ? 1 : 0)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 20)
                        //.frame(maxWidth: .infinity, alignment: .leading)
                    Text("Similar to how we follow instructions to tie shoelaces or follow a recipe, we all are following an algorithm.")
                        .multilineTextAlignment(.leading)
                        .font(.title3)
                        .padding()
                        .padding(.leading, 20)
                        .opacity(buttonCounter >= 2 ? 1 : 0)
                        //.frame(maxWidth: .infinity, alignment: .leading)
                    Text("Thus algorithms like A* are algorithms that are used to solve problems like: Finding the shortest path between 2 points in a reasonable time *(Pathfinding)*.")
                        //.frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .font(.title3)
                        .padding()
                        .padding(.leading, 20)
                        .opacity(buttonCounter >= 3 ? 1 : 0)
                    Text("Before diving straight in, let's explain some concepts that will be needed for their explainations!")
                        .font(.title3)
                        .opacity(buttonCounter >= 4 ? 1 : 0)
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 20)
                        .padding()
//                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    //Explain Heuristics here
                    Text("Heuristics in general terms are mental shortcuts or a 'rule of thumb'. They help to simplify complex decision-making.")
                        .font(.title3)
                        .padding()
                        .padding(.leading, 20)
                        .opacity(buttonCounter >= 1 ? 1 : 0)
                        .multilineTextAlignment(.leading)
                    Text("When you were solving the maze, did you notice that you usually consider paths that led in the direction of the goal?")
                        .font(.title3)
                        .padding()
                        .padding(.leading, 20)
                        .opacity(buttonCounter >= 2 ? 1 : 0)
                        .multilineTextAlignment(.leading)
                    Text("If not, that fine too! As a rule of thumb, when trying to find a path to a destination, heading in the direction of the destination usually works out.")
                        .font(.title3)
                        .padding()
                        .padding(.leading, 20)
                        .opacity(buttonCounter >= 3 ? 1 : 0)
                        .multilineTextAlignment(.leading)
                    Text("Heuristics in computer science and algorithms also mean the same thing! By using mental shortcuts *(heuristics)*, algorithms can be guided to a **good** answer but not necessarily the **best** answer.")
                        .font(.title3)
                        .padding()
                        .padding(.leading, 20)
                        .opacity(buttonCounter >= 4 ? 1 : 0)
                        .multilineTextAlignment(.leading)
                    Text("For A*, by using the stated rule of thumb *(heuristic)*, it will always return the shortest path in a weighted graph if the heuristic is consistent and not overestimating *(Further reading: Heuristic admissibility and consistency)*. Additionally, with the heuristic, it performs more efficiently than Dijkstra's Algorithm which do not use heurisitics but operate on the same principles.")
                        .font(.title3)
                        .padding()
                        .padding(.leading, 20)
                        .opacity(buttonCounter >= 5 ? 1 : 0)
                        .multilineTextAlignment(.leading)
                    Text("With that, let's learn about how does A* work!")
                        .font(.title3)
                        .padding()
                        .padding(.leading, 20)
                        .opacity(buttonCounter >= 6 ? 1 : 0)
                        .multilineTextAlignment(.leading)
                }
                Button {
                    withAnimation() {
                        buttonCounter += 1
                        if buttonCounter == 5 && !explainConcepts {
                            print("Transition to concept explaination")
                            buttonCounter = 0
                            explainConcepts = true
                            // RMB ADD button counter check
                        } else if explainConcepts && explainHeuristics && buttonCounter == 7{
                            showAlgorithmView.toggle()
                        } else if buttonCounter == 7 && !explainHeuristics {
                            print("Transition to heuristics explaination")
                            buttonCounter = 0
                            explainHeuristics = true
                        }
                        
                    }
                } label: {
                    Text("Next")
                        .frame(width: 210, height: 40, alignment: .center)
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(Color.blue))
                }.frame(maxWidth: .infinity)
            }
            //.fixedSize(horizontal: true, vertical: false)
            if showAlgorithmView {
                AlgorithmEduView(randomness: $randomness)
                    .transition(.move(edge: .trailing))
            }
        }
    }
}

#Preview {
    EduView(randomness: .constant(5))
}
