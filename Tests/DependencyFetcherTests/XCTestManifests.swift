//
//  XCTestManifests.swift
//  DependencyFetcher
//
//  Created by Sergej Jaskiewicz on 24/01/2019
//
//  GitHub
//  https://github.com/broadwaylamb/DependencyFetcher
//

import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(FetcherTests.allTests),
    ]
}
#endif
