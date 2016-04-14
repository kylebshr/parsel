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

    private var frontCamera: AVCaptureDevice?
    private var backCamera: AVCaptureDevice?

    private var currentPosition = AVCaptureDevicePosition.Unspecified

    var hasFrontAndBackCamera: Bool {
        return frontCamera != nil && backCamera != nil
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

        sessionPreset = AVCaptureSessionPresetMedium

        frontCamera = AVCaptureDevice.devices().filter {
            $0.hasMediaType(AVMediaTypeVideo) && $0.position == .Front
        }.first as? AVCaptureDevice

        backCamera = AVCaptureDevice.devices().filter {
            $0.hasMediaType(AVMediaTypeVideo) && $0.position == .Back
        }.first as? AVCaptureDevice

        if let frontCamera = frontCamera, input = try? AVCaptureDeviceInput(device: frontCamera) {
            currentPosition = .Front
            addInput(input)
        }
        else if let backCamera = backCamera, input = try? AVCaptureDeviceInput(device: backCamera) {
            currentPosition = .Back
            addInput(input)
        }

        addOutput(output)

        startRunning()
    }

    func switchPosition() {
        guard hasFrontAndBackCamera else { return }


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

        output.captureStillImageAsynchronouslyFromConnection(connection) { buffer, error in

            if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {

                let ciImage = CIImage(CVImageBuffer: pixelBuffer)
                let context = CIContext(options: nil)

                let image = context.createCGImage(ciImage, fromRect: CGRect(x: 0, y: 0,
                    width: CVPixelBufferGetWidth(pixelBuffer),
                    height: CVPixelBufferGetHeight(pixelBuffer)))

                let uiImage = UIImage(CGImage: image, scale: 1.0, orientation: UIImageOrientation.LeftMirrored)

                handler(image: uiImage)
            }
        }
    }
}
