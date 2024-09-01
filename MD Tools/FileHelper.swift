//
//  FileHelper.swift
//  MD Tools
//
//  Created by Stephan Ritchie on 27/07/2024.
//

import Foundation

class FileHelper {
    static func fileExists(at url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }

    static func deleteFile(at url: URL) throws {
        if fileExists(at: url) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                throw error
            }
        }
    }
}
