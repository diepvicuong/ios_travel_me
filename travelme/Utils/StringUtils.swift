//
//  StringUtils.swift
//  travelme
//
//  Created by DiepViCuong on 1/17/21.
//

import Foundation

extension String {
    func localized(with comment: String? = nil) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: comment ?? "")
    }
}
