//
//  ScannerView.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 22/12/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerView: UIView, AVCaptureMetadataOutputObjectsDelegate, IAlertView {
    
    private let captureSession = AVCaptureSession()
    
    private lazy var preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
    
    var onFound: (String)->Void = { privKey in }
    
    private let mOverlay = ScanView()
    
    private let mHint = UILabel.new(font: UIFont.medium(15.scaled), text: "scan_hint".loc, lines: 0, color: .black, alignment: .left)
    
    private let mError = UILabel.new(font: UIFont.medium(15.scaled), text: "error_desc".loc, lines: 0, color: .white, alignment: .center)
    
    var withHint: Bool = true {
        didSet {
            mHint.isVisible = withHint
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        preview.videoGravity  = .resizeAspectFill
        preview.cornerRadius  = 6.0
        preview.masksToBounds = true
        preview.backgroundColor = UIColor.black.cgColor
        
        layer.addSublayer(preview)
        addSubview(mHint)
        addSubview(mOverlay)
        addSubview(mError)
        
        mError.tap {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
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
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    func presentCameraSettings() {
        mError.isVisible  = true
        mOverlay.isHidden = true
    }
    
    private func request() {
        mError.isVisible  = false
        mOverlay.isHidden = false
        
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
    
    func layout(width: CGFloat, origin: CGPoint) {
        preview.frame  = CGRect(x: (width - 300.scaled)/2.0, y: 0, width: 300.scaled, height: 300.scaled)
        mOverlay.frame = preview.frame.insetBy(dx: -5, dy: -5)
        mError.frame   = preview.frame
        var bot = mError.maxY
        if mHint.isVisible {
            mHint.frame = CGRect(x: 0, y: preview.frame.maxY + 33.scaled, width: width,
                                 height: mHint.text?.heightFor(width: width, font: mHint.font) ?? 0)
            bot = mHint.maxY
        }
        frame = CGRect(origin: origin, size: CGSize(width: width, height: bot))
    }
    
}
