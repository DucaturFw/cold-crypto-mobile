//
//  ScannerVC.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 04/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import AVFoundation

class ScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    private let captureSession = AVCaptureSession()
    
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)

    var onFound: (String)->Void = { privKey in }
    
    private let mOverlay = ScanView()
    
    private let mBG = UIImageView(image: UIImage(named: "mainBG")).apply({
        $0.contentMode = .scaleAspectFill
    })
    
    private let mHint = UILabel.new(font: UIFont.hnRegular(18.scaled), text: "scan_hint".loc, lines: 0, color: .black, alignment: .left)
    
    private lazy var mClose = UIImageView(image: UIImage(named: "scanClose")).apply {
        $0.contentMode = .center
        $0.frame = $0.frame.insetBy(dx: -20, dy: -20)
    }.tap({ [weak self] in
        self?.dismiss(animated: true, completion: nil)
    })

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UIImageView(image: UIImage(named: "scan"))
        view.backgroundColor = .white
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.backgroundColor = UIColor.black.cgColor
        view.addSubview(mBG)
        view.layer.addSublayer(previewLayer)
        view.addSubview(mClose)
        view.addSubview(mHint)
        view.addSubview(mOverlay)
        
        let tmp = UISwipeGestureRecognizer(target: self, action: #selector(ScannerVC.close))
        tmp.direction = .down
        mClose.addGestureRecognizer(tmp)

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
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mBG.frame = view.bounds
        
        let t = navigationController?.navigationBar.maxY ?? 0
        
        previewLayer.frame = CGRect(x: 0, y: t, width: view.width, height: view.width / 376.0 * 275.0)
        mClose.origin = CGPoint(x: (view.width - mClose.width)/2.0, y: view.height - mClose.height - view.bottomGap)
        
        let s = previewLayer.frame.height
        let c = CGPoint(x: view.width/2.0, y: previewLayer.frame.height/2.0)
        mOverlay.frame = CGRect(x: 0, y: t + c.y - s/2.0, width: view.width, height: s)
        
        let w = view.width - 36.scaled
        mHint.frame = CGRect(x: 18.scaled, y: previewLayer.frame.maxY + 33.scaled,
                             width: w, height: mHint.text?.heightFor(width: w, font: mHint.font) ?? 0)
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
