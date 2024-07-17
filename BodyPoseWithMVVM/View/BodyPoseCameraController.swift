//
//  BodyPoseCameraController.swift
//  BodyPoseWithMVVM
//
//  Created by Kristanto Sean on 13/07/24.
//

import UIKit
import AVFoundation
import Vision
import SwiftUI

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var request: VNDetectHumanBodyPoseRequest!

    var drawingLayer: CAShapeLayer!
    
    var viewModel: BodyPoseViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupVision()
        setupDrawingLayer()
    }

    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        guard let camera = AVCaptureDevice.default(for: .video) else { return }
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            captureSession.addInput(input)
        } catch {
            print("Error accessing camera: \(error)")
            return
        }

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(output)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame

        captureSession.startRunning()
    }

    func setupVision() {
        request = VNDetectHumanBodyPoseRequest(completionHandler: handleBodyPose)
    }

    func setupDrawingLayer() {
        drawingLayer = CAShapeLayer()
        drawingLayer.frame = view.bounds
        drawingLayer.strokeColor = UIColor.red.cgColor
        drawingLayer.lineWidth = 2.0
        drawingLayer.fillColor = UIColor.clear.cgColor
        view.layer.addSublayer(drawingLayer)
    }
    
    func updateCamera() {
    }

    func handleBodyPose(request: VNRequest, error: Error?) {
        print("Handle body pose")
        guard let observations = request.results as? [VNHumanBodyPoseObservation] else { return }
        
        DispatchQueue.main.async {
            self.drawingLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
            print(observations)
            for observation in observations {
                self.processObservation(observation)
            }
        }
    }

    func processObservation(_ observation: VNHumanBodyPoseObservation) {
        do {
            let recognizedPoints = try observation.recognizedPoints(.all)
            
            // Filter points with a low confidence score
            let filteredPoints = recognizedPoints.filter { $0.value.confidence > 0.3 }

            var bodyPoints = [VNRecognizedPointKey:CGPoint]()
            for (_, point) in filteredPoints {
                let normalizedPoint = CGPoint(x: point.location.x, y: 1 - point.location.y)
                let convertedPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint: normalizedPoint)
                bodyPoints[point.identifier] = convertedPoint
                
                let dotLayer = createDot(at: convertedPoint)
                drawingLayer.addSublayer(dotLayer)
            }
            
            if let point1 = bodyPoints[VNHumanBodyPoseObservation.JointName.nose.rawValue],
               let point2 = bodyPoints[VNHumanBodyPoseObservation.JointName.neck.rawValue] {
                print("DRAWING NOSE-NECK")
                drawLines(between: [point1, point2])
            }

            if let point1 = bodyPoints[VNHumanBodyPoseObservation.JointName.neck.rawValue],
               let point2 = bodyPoints[VNHumanBodyPoseObservation.JointName.leftShoulder.rawValue] {
                print("DRAWING NECK-LEFT SHOULDER")
                drawLines(between: [point1, point2])
            }

            if let point1 = bodyPoints[VNHumanBodyPoseObservation.JointName.leftShoulder.rawValue],
               let point2 = bodyPoints[VNHumanBodyPoseObservation.JointName.leftElbow.rawValue] {
                print("DRAWING LEFT SHOULDER - ELBOW")
                drawLines(between: [point1, point2])
            }

            if let point1 = bodyPoints[VNHumanBodyPoseObservation.JointName.leftElbow.rawValue],
               let point2 = bodyPoints[VNHumanBodyPoseObservation.JointName.leftWrist.rawValue] {
                print("DRAWING LEFT ELBOW - WRIST")
                drawLines(between: [point1, point2])
            }

            if let point1 = bodyPoints[VNHumanBodyPoseObservation.JointName.neck.rawValue],
               let point2 = bodyPoints[VNHumanBodyPoseObservation.JointName.rightShoulder.rawValue] {
                print("DRAWING NECK - RIGHT SHOULDER")
                drawLines(between: [point1, point2])
            }
            
            if let point1 = bodyPoints[VNHumanBodyPoseObservation.JointName.rightShoulder.rawValue],
               let point2 = bodyPoints[VNHumanBodyPoseObservation.JointName.rightElbow.rawValue] {
                print("DRAWING RIGHT SHOULDER - ELBOW")
                drawLines(between: [point1, point2])
            }

            if let point1 = bodyPoints[VNHumanBodyPoseObservation.JointName.rightElbow.rawValue],
               let point2 = bodyPoints[VNHumanBodyPoseObservation.JointName.rightWrist.rawValue] {
                print("DRAWING RIGHT ELBOW - WRIST")
                drawLines(between: [point1, point2])
            }

            if let point1 = bodyPoints[VNHumanBodyPoseObservation.JointName.neck.rawValue],
               let point2 = bodyPoints[VNHumanBodyPoseObservation.JointName.root.rawValue] {
                print("DRAWING NECK - ROOT")
                drawLines(between: [point1, point2])
            }

            if let point1 = bodyPoints[VNHumanBodyPoseObservation.JointName.root.rawValue],
               let point2 = bodyPoints[VNHumanBodyPoseObservation.JointName.rightHip.rawValue] {
                print("DRAWING ROOT - RIGHT HIP")
                drawLines(between: [point1, point2])
            }

            if let point1 = bodyPoints[VNHumanBodyPoseObservation.JointName.rightHip.rawValue],
               let point2 = bodyPoints[VNHumanBodyPoseObservation.JointName.rightKnee.rawValue] {
                print("DRAWING RIGHT HIP - KNEE")
                drawLines(between: [point1, point2])
            }

            if let point1 = bodyPoints[VNHumanBodyPoseObservation.JointName.rightKnee.rawValue],
               let point2 = bodyPoints[VNHumanBodyPoseObservation.JointName.rightAnkle.rawValue] {
                print("DRAWING RIGHT KNEE - ANKLE")
                drawLines(between: [point1, point2])
            }

            if let point1 = bodyPoints[VNHumanBodyPoseObservation.JointName.root.rawValue],
               let point2 = bodyPoints[VNHumanBodyPoseObservation.JointName.leftHip.rawValue] {
                print("DRAWING ROOT - LEFT HIP")
                drawLines(between: [point1, point2])
            }
            
            if let point1 = bodyPoints[VNHumanBodyPoseObservation.JointName.leftHip.rawValue],
               let point2 = bodyPoints[VNHumanBodyPoseObservation.JointName.leftKnee.rawValue] {
                print("DRAWING LEFT HIP - KNEE")
                drawLines(between: [point1, point2])
            }

            if let point1 = bodyPoints[VNHumanBodyPoseObservation.JointName.leftKnee.rawValue],
               let point2 = bodyPoints[VNHumanBodyPoseObservation.JointName.leftAnkle.rawValue] {
                print("DRAWING LEFT KNEE - ANKLE")
                drawLines(between: [point1, point2])
            }


        } catch {
            print("Error processing observation: \(error)")
        }
    }

    func createDot(at point: CGPoint) -> CAShapeLayer {
        let dotLayer = CAShapeLayer()
        let dotPath = UIBezierPath(arcCenter: point, radius: CGFloat(viewModel.bodyStructure.width), startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        dotLayer.path = dotPath.cgPath
        dotLayer.fillColor = UIColor(viewModel.bodyStructure.pointColor).cgColor
        return dotLayer
    }

    func drawLines(between points: [CGPoint]) {
        guard points.count > 1 else { return }

        let linePath = UIBezierPath()
        for (index, point) in points.enumerated() {
            if index == 0 {
                linePath.move(to: point)
            } else {
                linePath.addLine(to: point)
            }
        }

        let lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.fillColor = UIColor(viewModel.bodyStructure.lineColor).cgColor
        lineLayer.lineWidth = CGFloat(viewModel.bodyStructure.width)
        drawingLayer.addSublayer(lineLayer)
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            print("Performing body pose")
            try handler.perform([request])
        } catch {
            print("Failed to perform body pose request: \(error)")
        }
    }
}

struct CameraPreview: UIViewControllerRepresentable {
    @ObservedObject var viewModel: BodyPoseViewModel
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController()
        viewController.viewModel = viewModel
        return viewController
    }
    
    func updateUIViewController(_ viewController: CameraViewController, context: Context) {
        viewController.viewModel = viewModel
        viewController.updateCamera()
    }
}
