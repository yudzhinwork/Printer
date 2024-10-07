import UIKit
import AVFoundation
import VisionKit
import Vision

final class ScannerViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate, VNDocumentCameraViewControllerDelegate {
    
    @IBOutlet private weak var scannerMaskImageView: UIImageView!
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var cameraView: UIView!
    private var photoOutput: AVCapturePhotoOutput!
    
    private var isFlashOn: Bool = false
    
    // Флаг, который отслеживает, был ли уже вызван VNDocumentCameraViewController
    private var documentCameraShown = false

    override func viewDidLoad() {
        super.viewDidLoad()
        startCameraSession()
        setupCameraView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !documentCameraShown {
            let documentCameraVC = VNDocumentCameraViewController()
            documentCameraVC.delegate = self
            present(documentCameraVC, animated: true, completion: nil)
            documentCameraShown = true  // Устанавливаем флаг в true после показа
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let tabBarController = self.tabBarController {
            tabBarController.tabBar.isHidden = false
        }
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        if scan.pageCount > 0 {
            let lastPageIndex = scan.pageCount - 1
            let scannedImage = scan.imageOfPage(at: lastPageIndex)
            
            if let imageData = scannedImage.jpegData(compressionQuality: 0.8) {
                let scanning = Scanning()
                scanning.imageData = imageData
                scanning.date = Date()
                scanning.recognizedText = generateRandomFileName()
                let realm = try! Realm()
                
                do {
                    try realm.write {
                        realm.add(scanning)
                        print("Image saved to Realm")
                    }
                } catch {
                    print("Error saving to Realm: \(error)")
                }
            }
            
            controller.dismiss(animated: true) {
                let resultVC = ScannerResultViewController()
                resultVC.fill(scannedImage)
                self.navigationController?.pushViewController(resultVC, animated: true)
            }
        }
    }
    
    func generateRandomFileName() -> String {
        let uuid = UUID().uuidString // Generate a unique identifier
        let timestamp = Int(Date().timeIntervalSince1970) // Add a timestamp for uniqueness
        return "file_\(uuid)_\(timestamp).pdf" // Customize the name and extension as needed
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true, completion: nil)
        print("Ошибка при сканировании: \(error.localizedDescription)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cameraView.frame = view.bounds
        previewLayer.frame = cameraView.bounds
    }
    
    private func setupCameraView() {
        cameraView = UIView(frame: view.bounds)
        cameraView.backgroundColor = .black
        view.addSubview(cameraView)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = cameraView.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)
        view.sendSubviewToBack(cameraView)
    }
    
    private func startCameraSession() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let camera = AVCaptureDevice.default(for: .video) else {
            print("No camera available")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Error setting up camera input: \(error)")
            return
        }
        
        photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        captureSession.startRunning()
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

    @IBAction func photoAction(_ sender: UIButton) {
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
         if let error = error {
             print("Error capturing photo: \(error.localizedDescription)")
             return
         }
         
         guard let imageData = photo.fileDataRepresentation(),
               let image = UIImage(data: imageData) else {
             print("Failed to create image from photo data")
             return
         }
        let vc = ScannerResultViewController()
        vc.fill(image)
        self.navigationController?.pushViewController(vc, animated: true)
         processImage(image)
     }

    private func processImage(_ image: UIImage) {
        guard let ciImage = CIImage(image: image) else {
            print("Не удалось преобразовать UIImage в CIImage")
            return
        }
        
        let textRecognitionRequest = VNRecognizeTextRequest(completionHandler: { (request, error) in
            if let results = request.results as? [VNRecognizedTextObservation] {
                for observation in results {
                    guard let topCandidate = observation.topCandidates(1).first else { continue }
                    print("Распознанный текст: \(topCandidate.string)")
                }
            } else if let error = error {
                print("Ошибка при распознавании текста: \(error.localizedDescription)")
            }
        })
        
        textRecognitionRequest.recognitionLevel = .accurate
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        do {
            try handler.perform([textRecognitionRequest])
        } catch {
            print("Ошибка при выполнении запроса: \(error.localizedDescription)")
        }
    }
}

import RealmSwift

class Scanning: Object {
    @objc dynamic var id = UUID().uuidString
    @objc dynamic var date = Date()
    @objc dynamic var imageData: Data? = nil
    @objc dynamic var recognizedText: String? = nil
    
    // Set the primary key
    override static func primaryKey() -> String? {
        return "id"
    }
}
