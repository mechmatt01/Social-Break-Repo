//
//  DateModel.swift
//  Social Break
//
//  Created by Grant Sivley on 2/26/21.
//

import Foundation

struct DateModel {
    func dateFormatter(format: String, timeStyle: DateFormatter.Style = .none) -> DateFormatter {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        dateformat.locale = Locale.current
        dateformat.timeStyle = .none
        return dateformat
    }
}
