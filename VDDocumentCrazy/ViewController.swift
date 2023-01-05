//
//  ViewController.swift
//  VDDocumentCrazy
//
//  Created by Tomato on 2022/12/31.
//

import UIKit
import Vision
import VisionKit

class ViewController: UIViewController, VNDocumentCameraViewControllerDelegate {
	// MARK: - Variables
	var viewController = VNDocumentCameraViewController()
	var textRecognitionRequest = VNRecognizeTextRequest(completionHandler: nil)
	let textRecognitionWorkQueue = DispatchQueue(label: "MyVisionScannerQueue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem, target: nil)
	
	
	// MARK: - IBOutlet
	
	
	// MARK: - IBAction
	@IBAction func scanTapped(_ sender: UIButton) {
		scanWithVNDocumentCamera()
	}
	
	
	// MARK: - Life cycle
	override func viewDidLoad() {
	   super.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {
	   super.viewWillAppear(animated)
	}

	override func viewDidAppear(_ animated: Bool) {
	   super.viewDidAppear(animated)
		setupVision()
	}
	
	
	// MARK: - VNDocumentCamera
	func setupVision() {
		textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
			guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
			var detectedText = ""
			for observation in observations {
				guard let topCandidate = observation.topCandidates(1).first else { return }
				print("text \(topCandidate.string) has confidence \(topCandidate.confidence)")
				detectedText += topCandidate.string
				detectedText += "\n"
			}
			print("Detected text: \(detectedText)")
		}
	}
	
	func scanWithVNDocumentCamera() {
		viewController.delegate = self
		present(viewController, animated: true)
	}
	
	func processImage(_ image: UIImage) {
		guard let cgImage = image.cgImage else {
			print("Oh, no...")
			return
		}
		textRecognitionWorkQueue.async {
			let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
			do {
				try requestHandler.perform([self.textRecognitionRequest])
			} catch {
				print(error)
			}
		}
	}
	
	
	// MARK: - VNDocumentCameraViewController delegate methods
	func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
		print("Found: \(scan.pageCount)")
		for i in 0..<scan.pageCount {
			let image = scan.imageOfPage(at: i)
			processImage(image)
		}
	}
	
	func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
		print("Cancelled")
		viewController.dismiss(animated: true)
	}
}

