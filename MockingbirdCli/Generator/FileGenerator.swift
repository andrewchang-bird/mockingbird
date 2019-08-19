//
//  FileGenerator.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/5/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import PathKit

// swiftlint:disable leading_whitespace

class FileGenerator {
  let mockableTypes: [String: MockableType]
  let moduleName: String
  let imports: Set<String>
  let outputPath: Path
  let shouldImportModule: Bool
  let preprocessorExpression: String?
  let onlyMockProtocols: Bool
  
  init(_ mockableTypes: [String: MockableType],
       moduleName: String,
       imports: Set<String>,
       outputPath: Path,
       preprocessorExpression: String?,
       shouldImportModule: Bool,
       onlyMockProtocols: Bool) {
    self.mockableTypes = onlyMockProtocols ?
      mockableTypes.filter({ $0.value.kind == .protocol }) :
      mockableTypes
    self.moduleName = moduleName
    self.imports = imports
    self.outputPath = outputPath
    self.preprocessorExpression = preprocessorExpression
    self.shouldImportModule = shouldImportModule
    self.onlyMockProtocols = onlyMockProtocols
  }
  
  var formattedDate: String {
    let date = Date()
    let format = DateFormatter()
    format.dateStyle = .short
    format.timeStyle = .none
    return format.string(from: date)
  }
  
  var outputFilename: String {
    return outputPath.components.last ?? "MockingbirdMocks.generated.swift"
  }
  
  private func generateFileHeader() -> String {
    let preprocessorDirective: String
    if let expression = preprocessorExpression {
      preprocessorDirective = "\n#if \(expression)\n"
    } else {
      preprocessorDirective = ""
    }
    
    let moduleImports = (
      ["@testable import Mockingbird"]
      + imports.union(["import Foundation"])
      + (shouldImportModule ? ["@testable import \(moduleName)"] : [])
    ).sorted()
    
    return """
    //
    //  \(outputFilename)
    //  \(moduleName)
    //
    //  Generated by Mockingbird on \(formattedDate).
    //  DO NOT EDIT
    //
    \(preprocessorDirective)
    \(moduleImports.joined(separator: "\n"))
    
    """
  }
  
  func generateFileBody() -> String {
    let memoizedContainer = MemoizedContainer()
    let operations = mockableTypes
      .map({ $0.value })
      .sorted(by: <)
      .map({ GenerateMockableTypeOperation(mockableType: $0,
                                           memoizedContainer: memoizedContainer) })
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = ProcessInfo.processInfo.activeProcessorCount
    queue.addOperations(operations, waitUntilFinished: true)
    return operations.map({ $0.result.generatedContents }).joined(separator: "\n\n")
  }
  
  private func generateFileFooter() -> String {
    return (preprocessorExpression != nil ? "\n#endif\n" : "")
  }
  
  private func generateFileContents() -> String {
    let sections = [
      generateFileHeader(),
      generateFileBody(),
      generateFileFooter(),
    ].filter({ !$0.isEmpty })
    return sections.joined(separator: "\n")
  }
  
  func generate() throws {
    try outputPath.write(generateFileContents(), encoding: .utf8)
  }
}
