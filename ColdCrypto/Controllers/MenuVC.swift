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
        case website = "website"
        case about = "about"
        
        var name: String {
            return rawValue.loc
        }
        
        var url: String {
            switch self {
            case .contact: return "http://coldcrypto.app/contact"
            case .userGuide: return "http://coldcrypto.app/guide"
            case .knowledge: return "http://coldcrypto.app/knowledge"
            case .privacy: return "http://coldcrypto.app/privacy"
            case .website: return "http://coldcrypto.app"
            case .about: return "http://coldcrypto.app/about"
            }
        }
        
    }
    
    private let mReset = Button().apply({
        $0.setTitle("reset".loc, for: .normal)
        $0.backgroundColor = 0xE26E7C.color
    })
    
    private let mItems = Item.allCases
    
    private lazy var mList = UITableView().apply({ [weak self] in
        $0.rowHeight = 44
        $0.backgroundView   = UIView()
        $0.backgroundColor  = UIColor.white
        $0.contentInset.top = 44.0
        $0.tableFooterView  = UIView()
        $0.delegate   = self
        $0.dataSource = self
        MenuCell.register(in: $0)
    })
    
    private let mInfo = UILabel.new(font: UIFont.hnRegular(12), lines: 1, color: UIColor.black.withAlphaComponent(0.5), alignment: .center).apply({
        $0.text = "ColdCrypto \(AppDelegate.version ?? "0.0").\(AppDelegate.build ?? "0")"
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.addSubview(mList)
        view.addSubview(mReset)
        view.addSubview(mInfo)
        
        mReset.click = { [weak self] in
            Alert(message: "sure_reset".loc)
                .set(positive: "reset_yes".loc, do: { [weak self] _ in
                    self?.dismiss(animated: true, completion: nil)
                    AppDelegate.resetWallet()
                })
                .set(negative: "reset_no".loc).show()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mList.frame  = view.bounds
        
        let w = view.width - 20.scaled
        let h = mInfo.text?.heightFor(width: w, font: mInfo.font) ?? 0
        
        mInfo.frame  = CGRect(x: 10.scaled, y: view.height - h - 10.scaled - view.bottomGap, width: w, height: h)
        mReset.frame = CGRect(x: 10.scaled, y: mInfo.minY - 55.scaled, width: w, height: 44.scaled)
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource methods
    // -------------------------------------------------------------------------
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MenuCell.get(from: tableView, at: indexPath)
        cell.textLabel?.text = mItems[indexPath.row].name
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
