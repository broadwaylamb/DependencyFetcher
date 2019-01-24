//
//  FetcherTests.swift
//  DependencyFetcher
//
//  Created by Sergej Jaskiewicz on 24/01/2019
//
//  GitHub
//  https://github.com/broadwaylamb/DependencyFetcher
//

import XCTest
import DependencyFetcher

final class FetcherTests: XCTestCase {

  static let allTests = [
    ("testDefaultFetcher", testDefaultFetcher),
    ("testFetcherWithOverrides", testFetcherWithOverrides),
  ]

  func testDefaultFetcher() {

    let fetcher = Fetcher.createDefault()
    let logger = fetcher.fetch(.logger)
    XCTAssertTrue(logger is LoggerImpl1)

    // Test that when asked twice, Fetcher returns the same instance.
    let againLogger = fetcher.fetch(.logger)
    XCTAssertTrue(logger === againLogger)
  }

  func testFetcherWithOverrides() {

    let fetcher = Fetcher
      .create()
      .addOverride(for: Service.logger, instance: LoggerImpl2())
      .done()

    let logger = fetcher.fetch(.logger)
    XCTAssertTrue(logger is LoggerImpl2)

    // Test that when asked twice, Fetcher returns the same instance.
    let againLogger = fetcher.fetch(.logger)
    XCTAssertTrue(logger === againLogger)
  }
}

private protocol Logger: AnyObject {
  func log(_ text: String)
}

private final class LoggerImpl1: Logger {
  private var log: String = ""
  func log(_ text: String) {
    print(text, to: &log)
  }
}

private final class LoggerImpl2: Logger {
  private var log: String = ""
  func log(_ text: String) {
    print(text, to: &log)
  }
}

private extension Service where T == Logger {
  static let logger = Service(LoggerImpl1())
}
