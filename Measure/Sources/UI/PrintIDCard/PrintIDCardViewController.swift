//
//  PrintIDCardViewController.swift
//  Printer

import UIKit
import AVFoundation

class PrintIDCardViewController: BaseViewController {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var capturePhotoOutput: AVCapturePhotoOutput!
    
    private var isFlashOn: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCamera()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo

        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            captureSession.addInput(input)

            capturePhotoOutput = AVCapturePhotoOutput()
            captureSession.addOutput(capturePhotoOutput)
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = view.layer.bounds
            view.layer.addSublayer(previewLayer)

            captureSession.startRunning()
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    @IBAction func photoAction(_ sender: UIButton) {
        let photoSettings = AVCapturePhotoSettings()
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @IBAction func flashAction(_ sender: UIButton) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
             print("Torch is not available.")
             return
         }
         
         do {
             try device.lockForConfiguration()
             
             if isFlashOn {
                 device.torchMode = .off
                 isFlashOn = false
             } else {
                 try device.setTorchModeOn(level: 1.0)
                 isFlashOn = true
             }
             
             device.unlockForConfiguration()
         } catch {
             print("Error accessing the torch: \(error)")
         }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension PrintIDCardViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let photoData = photo.fileDataRepresentation(), let image = UIImage(data: photoData) else {
            return
        }
        
        let vc = PrintIDCardCropViewController()
        vc.fill(image)
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
}
