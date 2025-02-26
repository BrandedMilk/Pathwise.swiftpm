//
//  WelcomeView.swift
//  Pathwise
//
//  Created by Zhang Hongliang on 17/2/25.
//

import Foundation
import SwiftUI

struct WelcomeView: View {
    @State var showMazeView = false
    @State var showDebug = false
    
    var body: some View {
        ZStack {
//            Color.init(red: 210/255, green: 210/255, blue: 210/255)
//                .ignoresSafeArea()
            Rectangle()
                .fill(Color(UIColor.systemGray6))
                .ignoresSafeArea()
//                VStack {
//                    Text("Pathwise")
//                        .bold()
//                        .font(.system(size: 50, weight: .bold, design: .default))
//                    Text("Teaching you the A* algorithm, one step at a time.")
//                        .font(.title)
//                    Text("Mazes being solved video? Cycling through different versions")
//                        .frame(width: 500, height: 500, alignment: .center)
//                        .background(Rectangle().fill(Color.black))
//                        .font(.system(size: 25))
//                        .foregroundStyle(.white)
//                }
                VStack{
                    Text("Pathwise")
                        .bold()
                        .font(.system(size: 50, weight: .bold, design: .default))
                    Text("Teaching you the A* algorithm, one step at a time.")
                        .font(.title)
                        .padding(.bottom)
                    
                    Button {
                        withAnimation {
                            showMazeView.toggle()
                        }
                    } label: {
                        Text("Start")
                            .frame(width: 500, height: 50, alignment: .center)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(Color.blue))
                    }.padding()
//                    Button {
//                        withAnimation {
//                            showDebug.toggle()
//                        }
//                    } label: {
//                        Text("Debug: AlgorithmEduView")
//                            .frame(width: 500, height: 50, alignment: .center)
//                            .font(.title)
//                            .fontWeight(.semibold)
//                            .foregroundStyle(.white)
//                            .background(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)).fill(Color.blue))
//                    }
                }
            if showMazeView {
                MazeView()
            }
//            if showDebug {
//                AlgorithmEduView(randomness: .constant(5))
//            }
        }
    }
    
}

#Preview {
    WelcomeView()
}
