# DependencyFetcher
[![Build Status](https://travis-ci.org/broadwaylamb/DependencyFetcher.svg?branch=master)](https://travis-ci.org/broadwaylamb/DependencyFetcher)
[![codecov](https://codecov.io/gh/broadwaylamb/DependencyFetcher/branch/master/graph/badge.svg)](https://codecov.io/gh/broadwaylamb/DependencyFetcher)
![Language](https://img.shields.io/badge/Swift-4.2-orange.svg)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey.svg)
![Cocoapods](https://img.shields.io/cocoapods/v/DependencyFetcher.svg?style=flat)

World's simplest dependency injection framework for Swift.

- [x] Thread-safe.
- [x] Just ~60 source lines of code.
- [x] Works on any platform, including Linux, doesn't depend on Foundation.
- [x] Doesn't use global state.
- [x] Doesn't require any configuration at all.

## Requirements

- macOS / iOS / watchOS / tvOS / Linux
- Swift 4.2+

## Usage

#### Define the services

```swift
protocol Logger {
  // ...
}

protocol Database {
  // ...
}

class StdOutLogger: Logger {
  init() { /*...*/ }
}

class CoreDataDatabase: Database {
  static func setup() -> CoreDataDatabase { /*...*/ }
}
```

#### Extend the `Service` class

```swift
extension Service where T == Logger {
  static let logger = Service(StdOutLogger.init)
  static let database = Service(CoreDataDatabase.setup)
}
```

#### Fetch the dependencies in application code

Create an instance of `Fetcher` somewhere in your code:

```swift
let fetcher = Fetcher.createDefault()
```

You can then pass this instance around using, e. g., injection via initializer.
That's right, you don't have to register your services anywhere except defining them as static properties of the `Service` class.

Then, when you need your dependencies, just call:

```swift
let logger = self.fetcher.fetch(.logger) // logger has the type Logger
let database = self.fetcher.fetch(.database) // database has the type Database
```

#### Mock services in tests

Your application code doesn't need to (and even should not) be aware of whether it is being executed during testing or not. When you need to mock your dependencies, just create a `Fetcher` instance and override the needed services with their mocks:

```swift
let fetcher = Fetcher
  .create()
  .addOverride(for: Service.logger, instance: MockLogger())
  .addOverride(for: Service.database, instance: MockDatabase())
  .done()
```

And then pass this instance to the units you're testing.

#### Factoring out hard-coded dependencies

Often you have a large codebase that uses hard-coded dependencies (singletons etc.) all over the place, and you just can't refactor **all** your code at once. `DependencyFetcher ` can be introduced to your codebase incrementally.

Suppose you have a view controller that does this (quite common MVC code):

```swift
class ViewController: UIViewControlelr {

  var products: [Product] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    APIEndpoint.default.getProducts(onSuccess: { self.products = $0 },
                                    onError: {error in /*...*/ })
  }
}
```

This is really hard to test. We can refactor a little bit:

```swift

protocol APIEndpointProtocol {
  func getProducts(onSuccess: @escaping ([Product]) -> Void,
                   onError: @escaping (Error) -> Void)
}

extension APIEndpoint: APIEndpointProtocol {}

extension Service where T == APIEndpointProtocol {
  static let apiEndpoint = Service(APIEndpoint.default)
}

class ViewController: UIViewControlelr {

  var products: [Product] = []
  
  var fetcher = Fetcher.createDefault()
  
  private lazy var apiEndpoint = self.fetcher.fetch(.apiEndpoint)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.apiEndpoint.getProducts(onSuccess: { self.products = $0 },
                                 onError: { error in /*...*/ })
  }
}
```

And now we can easily test our `ViewController`:

```swift
class MockAPIEndpoint: APIEndpointProtocol {
  
  let testProducts: [Product] = [
    // ...
  ]

  func getProducts(onSuccess: @escaping ([Product]) -> Void,
                   onError: @escaping (Error) -> Void) {
    onSuccess(self.testProducts)                 
  }
}
```

```swift
func testPopulatingViewControllerWithProducts() {
  let vc = ViewController()
  let mock = MockAPIEndpoint()
  vc.fetcher = Fetcher
    .create()
    .addOverride(for: Service.apiEndpoint, instance: mock)
    .done()
    
  vc.viewDidLoad()
  
  XCTAssertEqual(vc.products, mock.testProducts)
}
```


## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
  .package(url: "https://github.com/broadwaylamb/DependencyFetcher.git",
           from: "1.0.0"),
]
```

### CocoaPods

Add the following to your `Podfile`:

```ruby
target 'MyApp' do
  pod 'DependencyFetcher', '~> 1.0'
end
```
