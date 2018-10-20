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
    
    enum BackStyle {
        case toRoot, toPrevious
    }
    
    enum HintStyle {
        case newImport, export, address
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private let captureSession = AVCaptureSession()
    
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    
    private let mHint = UILabel.new(font: .sfProMedium(14), lines: 0, color: .white, alignment: .center)
    
    private let mContainer: UIView = {
        let tmp = UIView()
        tmp.layer.cornerRadius = 6
        tmp.layer.masksToBounds = true
        return tmp
    }()
    
    private let mBlur: UIVisualEffectView = {
        let tmp = UIVisualEffectView()
        tmp.effect = UIBlurEffect(style: .regular)
        return tmp
    }()
    
    private let mDown: UIImageView = {
        let tmp = UIImageView(image: UIImage(named: "arrowTopWhite"))
        tmp.contentMode = .center
        tmp.frame = tmp.frame.insetBy(dx: -20, dy: -20)
        tmp.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
        tmp.tintColor = .white
        return tmp
    }()

    private let mTitle = UILabel.new(font: .sfProSemibold(17),
                                     text: "scan_title".loc,
                                     lines: 1,
                                     color: UIColor.white,
                                     alignment: .center)
    
    var onFound: (String)->Void = { privKey in }
    
    private let mLogic: BackStyle
    
    private let mOverlay = ScanView()
    
    private let mHintStyle: HintStyle
    
    private var mBackButton: UIView?
    
    init(backStyle: BackStyle = .toPrevious, hintStyle: HintStyle = .newImport) {
        mLogic = backStyle
        mHintStyle = hintStyle
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        view.addSubview(mOverlay)
        view.addSubview(mTitle)

        mBackButton = UIImageView(image: UIImage(named: navigationController?.viewControllers.count != 1 ? "backWhite" : "arrowTopWhite"))
        mBackButton?.contentMode = .left
        mBackButton?.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        mBackButton?.tap({ [weak self] in self?.backAction() })
        if (navigationController?.viewControllers.count ?? 0) <= 1 {
            mBackButton?.transform = CGAffineTransform(scaleX: 1.0, y: -1.0)
        }
        if let v = mBackButton {
            view.addSubview(v)
        }
        
        mDown.tap({ [weak self] in self?.backAction() })
        
        mContainer.addSubview(mBlur)
        mContainer.addSubview(mHint)
        view.addSubview(mContainer)
        view.addSubview(mDown)
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(ScannerVC.backAction))
        gesture.direction = .down
        view.addGestureRecognizer(gesture)
        
        switch mHintStyle {
        case .newImport: mHint.text = "scan_new_import".loc
        case .export: mHint.text = "scan_line_1".loc
        case .address: mHint.text = "scan_line_2".loc
        }

        guard let device = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: device)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else { return }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else { return }
    }

    @objc func backAction() {
        if navigationController?.viewControllers.count != 1 {
            if mLogic == .toRoot {
                navigationController?.popToRootViewController(animated: true)
            } else {
                navigationController?.popViewController(animated: true)
            }
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.layer.bounds

        let w = min(mHint.text?.width(with: mHint.font) ?? 0.0, view.width - 60)
        let h = mHint.text?.heightFor(width: w, font: mHint.font) ?? 0.0
        mHint.frame = CGRect(x: 10, y: 10, width: w, height: h)

        mDown.isHidden = mLogic == .toRoot
        mDown.origin = CGPoint(x: (view.width - mDown.width)/2.0, y: view.height - mDown.height - view.bottomGap - 20)
        
        mContainer.frame = CGRect(x: (view.width - w - 20)/2.0, y: (mDown.isVisible ? mDown.minY : view.height) - h - 30 - view.bottomGap, width: w + 20, height: h + 20)
        mBlur.frame = mContainer.bounds
        mOverlay.frame = view.bounds
        mTitle.center = CGPoint(x: view.width / 2.0, y: UIApplication.shared.statusBarFrame.height + 22)
        mBackButton?.origin = CGPoint(x: 16, y: UIApplication.shared.statusBarFrame.height + 2.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        if mLogic == .toRoot {
            navigationController?.interactivePopGestureRecognizer?.delegate  = nil
            navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
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

    func stop() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
        mOverlay.pause()
    }
    
}
