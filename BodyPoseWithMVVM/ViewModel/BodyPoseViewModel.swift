//
//  BodyPoseViewModel.swift
//  BodyPoseWithMVVM
//
//  Created by Kristanto Sean on 13/07/24.
//

import Foundation

class BodyPoseViewModel: ObservableObject {
    
    @Published var bodyStructure = HumanBody(lineColor: .red, width: 10, pointColor: .green)
    
}
