//
//  ContentView.swift
//  BodyPoseWithMVVM
//
//  Created by Kristanto Sean on 13/07/24.
//

import SwiftUI

struct BodyPoseView: View {
    
    @StateObject var viewModel = BodyPoseViewModel()
    
    var body: some View {
        VStack {
            
            CameraPreview(viewModel: viewModel)

            ZStack {
                Color(.black)
                    .opacity(0.5)
                    .ignoresSafeArea()
                
                VStack {
                    ColorPicker(selection: $viewModel.bodyStructure.lineColor){
                        Text("Line Color")
                    }.padding(.horizontal)
                    
                    HStack {
                        Text("Line Width")
                        Slider(value: $viewModel.bodyStructure.width, in: 1...10)
                    }.padding(.horizontal)

                    ColorPicker(selection: $viewModel.bodyStructure.pointColor){
                        Text("Point Color")
                    }.padding(.horizontal)
                }
            }.ignoresSafeArea()

        }
        .padding()
    }
}

#Preview {
    BodyPoseView()
}
