//
//  String+Extension.swift
//  Startup Show
//
//  Created by David Rozmajzl on 4/14/24.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
