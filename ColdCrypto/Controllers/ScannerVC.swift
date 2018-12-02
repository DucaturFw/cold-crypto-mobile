//
//  ScannerVC.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 04/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerVC: PopupVC, AVCaptureMetadataOutputObjectsDelegate {
    
    private let captureSession = AVCaptureSession()
    
    private lazy var preview = AVCaptureVideoPreviewLayer(session: self.captureSession)

    var onFound: (String)->Void = { privKey in }
    
    private let mOverlay = ScanView()
    
    private let mArrow = UIImageView(image: UIImage(named: "arrowDown"))
    private let mHint = UILabel.new(font: UIFont.medium(15.scaled), text: "scan_hint".loc, lines: 0, color: .black, alignment: .left)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preview.videoGravity  = .resizeAspectFill
        preview.cornerRadius  = 6.0
        preview.masksToBounds = true
        preview.backgroundColor = UIColor.black.cgColor
        
        content.layer.addSublayer(preview)
        content.addSubview(mHint)
        content.addSubview(mOverlay)
        content.addSubview(mArrow)
        
        if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
            request()
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { [weak self] result in
                DispatchQueue.main.async {
                    if result {
                        self?.request()
                    } else {
                        self?.presentCameraSettings()
                    }
                }
            })
        }
    }

    func presentCameraSettings() {
        let alert = UIAlertController(title: "error".loc,
                                      message: "error_desc".loc,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "cancel".loc, style: .default))
        alert.addAction(UIAlertAction(title: "go_settings".loc, style: .cancel) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        present(alert, animated: true)
    }
    
    private func request() {
        let metadataOutput = AVCaptureMetadataOutput()
        if let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(input),
            captureSession.canAddOutput(metadataOutput) {
            captureSession.addInput(input)
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            if metadataOutput.availableMetadataObjectTypes.contains(.qr) {
                metadataOutput.metadataObjectTypes = [.qr]
            }
        }
    }

    override func doLayout() -> CGFloat {        
        mArrow.origin  = CGPoint(x: (width - mArrow.width)/2.0, y: 40.scaled)
        preview.frame  = CGRect(x: (width - 300.scaled)/2.0, y: mArrow.maxY + 40.scaled, width: 300.scaled, height: 300.scaled)
        mOverlay.frame = preview.frame.insetBy(dx: -5, dy: -5)
        
        let w = width - 36.scaled
        mHint.frame = CGRect(x: 18.scaled, y: preview.frame.maxY + 33.scaled,
                             width: w, height: mHint.text?.heightFor(width: w, font: mHint.font) ?? 0)
        return mHint.maxY + 30.scaled
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stop()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let key = obj.stringValue {
            onFound(key)
        }
    }

    func start() {
        if !captureSession.isRunning && captureSession.outputs.count > 0 {
            captureSession.startRunning()
        }
    }
    
    func stop() {
        mOverlay.pause()
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }

}
