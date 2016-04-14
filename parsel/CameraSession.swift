    //
//  Session.swift
//  Snapstahp
//
//  Created by Kyle Bashour on 4/13/16.
//  Copyright © 2016 Kyle Bashour. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO
import CoreMedia

class CameraSession: AVCaptureSession {

    private var frontInput: AVCaptureInput!
    private var backInput: AVCaptureInput!

    private var currentPosition = AVCaptureDevicePosition.Unspecified

    var hasFrontAndBackCamera: Bool {
        return frontInput != nil && backInput != nil
    }

    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: self)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        return previewLayer
    }()

    private let output: AVCaptureStillImageOutput = {
        let output = AVCaptureStillImageOutput()
        output.outputSettings = [kCVPixelBufferPixelFormatTypeKey: NSNumber(unsignedInt: kCMPixelFormat_32BGRA)]
        return output
    }()

    override init() {
        super.init()

        sessionPreset = AVCaptureSessionPresetPhoto

        let frontCamera = AVCaptureDevice.devices().filter {
            $0.hasMediaType(AVMediaTypeVideo) && $0.position == .Front
        }.first as? AVCaptureDevice
        let backCamera = AVCaptureDevice.devices().filter {
            $0.hasMediaType(AVMediaTypeVideo) && $0.position == .Back
        }.first as? AVCaptureDevice

        if let backCamera = backCamera, input = try? AVCaptureDeviceInput(device: backCamera) {

            do {
                try backCamera.lockForConfiguration()
                backCamera.focusMode = .ContinuousAutoFocus
                backCamera.unlockForConfiguration()
            } catch {
                print("Failed to lock back camera")
            }

            backInput = input
        }
        if let frontCamera = frontCamera, input = try? AVCaptureDeviceInput(device: frontCamera) {
            frontInput = input
        }

        if let input = frontInput {
            currentPosition = .Front
            addInput(input)
        }
        else if let input = backInput {
            currentPosition = .Back
            addInput(input)
        }

        addOutput(output)

        startRunning()
    }

    func switchPosition() {
        guard hasFrontAndBackCamera else { return }

        let removing = currentPosition == .Back ? backInput : frontInput
        let adding = currentPosition == .Back ? frontInput : backInput

        removeInput(removing)
        addInput(adding)

        currentPosition = currentPosition == .Back ? .Front : .Back
    }

    func capturePhoto(handler: (image: UIImage) -> Void) {

        var videoConnection: AVCaptureConnection?

        for connection in output.connections as! [AVCaptureConnection] {
            for input in connection.inputPorts as! [AVCaptureInputPort] {
                if input.mediaType == AVMediaTypeVideo {
                    videoConnection = connection
                }
            }
        }

        guard let connection = videoConnection else {
            return
        }

        output.captureStillImageAsynchronouslyFromConnection(connection) { [unowned self] buffer, error in

            if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {

                let ciImage = CIImage(CVImageBuffer: pixelBuffer)
                let context = CIContext(options: nil)

                let image = context.createCGImage(ciImage, fromRect: CGRect(x: 0, y: 0,
                    width: CVPixelBufferGetWidth(pixelBuffer),
                    height: CVPixelBufferGetHeight(pixelBuffer)))

                let orientation = self.currentPosition == .Front ? UIImageOrientation.LeftMirrored : UIImageOrientation.Right

                let uiImage = UIImage(CGImage: image, scale: 1.0, orientation: orientation)

                handler(image: uiImage)
            }
        }
    }
}
