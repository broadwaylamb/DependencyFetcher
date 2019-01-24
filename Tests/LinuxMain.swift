//
//  LinuxMain.swift
//  DependencyFetcher
//
//  Created by Sergej Jaskiewicz on 24/01/2019
//
//  GitHub
//  https://github.com/broadwaylamb/DependencyFetcher
//

import XCTest

import DependencyFetcherTests

var tests = [XCTestCaseEntry]()
tests += DependencyFetcherTests.allTests()
XCTMain(tests)