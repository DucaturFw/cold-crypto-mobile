//
//  MoreTxVC.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 25/01/2019.
//  Copyright © 2019 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class MoreTxVC: AlertVC {
    
    class Picker: UIView, IAlertView {
        
        let share = Button().apply {
            $0.backgroundColor = Style.Colors.darkGrey
            $0.setTitle("share".loc, for: .normal)
        }
        
        let open = Button().apply {
            $0.backgroundColor = Style.Colors.darkGrey
            $0.setTitle("open".loc, for: .normal)
        }

        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(share)
            addSubview(open)
        }
        
        required init?(coder aDecoder: NSCoder) {
            return nil
        }
        
        func layout(width: CGFloat, origin o: CGPoint) {
            share.frame = CGRect(x: 0, y: 0, width: width, height: Style.Dims.middle)
            open.frame = share.frame.offsetBy(dx: 0, dy: share.height + 20.scaled)
            frame = CGRect(x: o.x, y: o.y, width: width, height: open.maxY)
        }
        
    }

    init(image: UIImage?, transaction: ITransaction) {
        let v = Picker()
        super.init(nil, view: v, style: .sheet, arrow: true, withButtons: false)
        v.share.click = { [weak self] in
            self?.dismiss(animated: true, completion: nil)
            AppDelegate.share(image: image, text: transaction.hash)
        }
        v.open.click = {
            if let url = transaction.url, UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }

}
