//
//  TokenPicker.swift
//  ColdCrypto
//
//  Created by Kirill Kozhuhar on 25/02/2019.
//  Copyright © 2019 Kirill Kozhuhar. All rights reserved.
//

import UIKit

class TokenPicker: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let rows: [ETHToken]
    
    var onSelected: (ETHToken, Int)->Void = { _, _ in }

    init(range: [ETHToken]) {
        rows = range
        super.init(frame: .zero)
        dataSource = self
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rows[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return rows.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        onSelected(rows[row], row)
    }
        
}
