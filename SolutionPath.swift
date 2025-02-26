//
//  SolutionPath.swift
//  Pathwise
//
//  Created by Zhang Hongliang on 17/2/25.
//

import SwiftUI

// MARK: - This will draw the solution path derived from the code for drawing the solution path in each cell in MazeView. Will have to accept mazeCell array. Then use .trim() to get the self drawing effect.

struct SolutionPath: Shape {
    nonisolated func path(in rect: CGRect) -> Path {
        return Path()
    }
}
