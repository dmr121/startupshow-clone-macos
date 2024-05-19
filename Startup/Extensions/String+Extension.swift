//
//  String+Extension.swift
//  Startup Show
//
//  Created by David Rozmajzl on 4/14/24.
//

import Foundation

extension String {
    func trimmed() -> Self {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
