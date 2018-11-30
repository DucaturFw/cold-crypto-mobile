//
//  MenuVC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 03/11/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import UIKit
import SideMenu

class MenuVC : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    enum Item: String, CaseIterable {
        
        case contact = "contact"
        case userGuide = "user_guide"
        case knowledge = "knowledge"
        case privacy = "privacy"
        case about = "about"
        
        var name: String {
            return rawValue.loc
        }
        
        var imageName: String {
            switch self {
            case .contact: return "iconContact"
            case .userGuide: return "userGuide"
            case .knowledge: return "knowledge"
            case .privacy: return "privacy"
            case .about: return "about"
            }
        }
        
        var url: String {
            switch self {
            case .contact: return "http://coldcrypto.app/contact"
            case .userGuide: return "http://coldcrypto.app/guide"
            case .knowledge: return "http://coldcrypto.app/knowledge"
            case .privacy: return "http://coldcrypto.app/privacy"
            case .about: return "http://coldcrypto.app/about"
            }
        }
        
    }
    
    private let mReset = Button().apply({
        $0.setTitle("reset".loc, for: .normal)
        $0.backgroundColor = Style.Colors.red
    })
    
    private let mItems = Item.allCases
    
    private lazy var mList = UITableView().apply({ [weak self] in
        $0.rowHeight = 44.scaled
        $0.backgroundView   = UIView()
        $0.backgroundColor  = UIColor.white
        $0.contentInset.top = 16.scaled + AppDelegate.statusHeight
        $0.tableFooterView  = UIView()
        $0.separatorStyle   = .none
        $0.delegate   = self
        $0.dataSource = self
        MenuCell.register(in: $0)
    })
    
    private let mInfo = UILabel.new(font: .pro(12.scaled), lines: 1, color: UIColor.black.withAlphaComponent(0.5), alignment: .center).apply({
        $0.text = "ColdCrypto \(AppDelegate.version ?? "0.0").\(AppDelegate.build ?? "0")"
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(mList)
        view.addSubview(mReset)
        view.addSubview(mInfo)
        mReset.click = { [weak self] in
            Alert("sure_reset".loc).put("reset_no".loc)
                .put("reset_yes".loc, color: 0xE26E7C.color, do: { [weak self] _ in
                    self?.dismiss(animated: true, completion: nil)
                    AppDelegate.resetWallet()
                }).show()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mList.frame  = view.bounds
        
        let w = 195.scaled
        let h = mInfo.text?.heightFor(width: w, font: mInfo.font) ?? 0
        
        mInfo.frame  = CGRect(x: (view.width - w)/2.0, y: view.height - h - 10.scaled - AppDelegate.bottomGap, width: w, height: h)
        mReset.frame = CGRect(x: (view.width - w)/2.0, y: mInfo.minY - 55.scaled, width: w, height: 44.scaled)
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource methods
    // -------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MenuCell.get(from: tableView, at: indexPath)
        cell.set(name: mItems[indexPath.row].name, icon: UIImage(named: mItems[indexPath.row].imageName))
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mItems.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url = URL(string: mItems[indexPath.row].url), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        dismiss(animated: true, completion: nil)
    }
    
}
