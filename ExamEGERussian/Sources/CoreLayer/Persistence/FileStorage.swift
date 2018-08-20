//
//  FileStorage.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 20/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class FileStorage {
    typealias CompletionHandler = (_ url: URL?, _ error: Error?) -> Void

    private let destinationDirectory: URL
    private let queue = OperationQueue()

    init(destination: Destination) {
        self.destinationDirectory = FileStorage.processDestination(destination)
    }

    // MARK: - Public API -

    /// Persists `Encodable` item.
    func persist<T: Encodable>(item: T, named fileName: String, with completion: @escaping CompletionHandler) {
        do {
            let data = try JSONEncoder().encode(item)
            persist(data: data, named: fileName, with: completion)
        } catch let error {
            completion(nil, error)
        }
    }

    /// Persists raw data at the specified location with `CompletionHandler`.
    func persist(data: Data, named fileName: String, with completion: @escaping CompletionHandler) {
        var url: URL?
        var error: Error?

        // Create an operation to process the request.
        let operation = BlockOperation {
            do {
                url = try self.persist(data: data, at: self.getFileURL(at: fileName))
            } catch let persistenceError {
                error = persistenceError
            }
        }

        operation.completionBlock = {
            completion(url, error)
        }

        queue.addOperation(operation)
    }

    /// Load cached data from the specified location.
    public func loadData(fileName: String) -> Data? {
        return FileManager.default.contents(atPath: getFileURL(at: fileName).path)
    }

    /// Load cached data from the specified location and decodes it.
    public func load<T: Codable>(fileName: String) -> T? {
        guard let data = loadData(fileName: fileName),
              let decoded = try? JSONDecoder().decode(T.self, from: data) else {
                return nil
        }

        return decoded
    }

    // MARK: - Private API -

    private func persist(data: Data, at url: URL) throws -> URL {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(atPath: url.path)
        }
        fileManager.createFile(atPath: url.path, contents: data, attributes: nil)

        return url
    }

    private func getFileURL(at path: String) -> URL {
        return self.destinationDirectory.appendingPathComponent(path, isDirectory: false)
    }

    /// Returns folder URL.
    private static func processDestination(_ destination: Destination) -> URL {
        var documentFolder: URL
        switch destination {
        case .temporary:
            documentFolder = getURL(for: .cachesDirectory)
        case .atFolder(let folderName):
            documentFolder = getURL(for: .documentDirectory)
            if let folderName = folderName {
                documentFolder = documentFolder.appendingPathComponent(folderName, isDirectory: true)
            }
        }

        try? FileManager.default.createDirectory(
            at: documentFolder,
            withIntermediateDirectories: true,
            attributes: nil
        )

        return documentFolder
    }

    /// Returns URL constructed from specified directory.
    private static func getURL(for directory: FileManager.SearchPathDirectory) -> URL {
        if let url = FileManager.default.urls(for: directory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Could not create URL for specified directory!")
        }
    }

    enum Destination {
        /// Stores items in temporary directory
        case temporary
        /// Stores items at a specific location
        /// If `nil` was specified returns root
        case atFolder(name: String?)
    }
}
