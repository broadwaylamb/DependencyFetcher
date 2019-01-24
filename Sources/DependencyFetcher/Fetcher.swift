//
//  Fetcher.swift
//  DependencyFetcher
//
//  Created by Sergej Jaskiewicz on 24/01/2019
//
//  GitHub
//  https://github.com/broadwaylamb/DependencyFetcher
//

import Dispatch

/// A type that wraps a service of type `T` so that later it can be fetched
/// by `Fetcher`.
///
/// You add static members to this type using Swift's `extension` mechanism:
///
/// ```swift
/// protocol Logger: AnyObject {
///   func log(_ text: String)
/// }
///
/// class StdOutLogger: Logger {
///   init() { /*...*/ }
///   func log(_ text: String) { /*...*/ }
/// }
///
/// extension Service where T == Logger {
///   static let logger = Service(StdOutLogger.init)
/// }
/// ```
///
/// Then you can use an instance of `Fetcher` to create and return your service:
///
/// ```swift
/// let logger = fetcher.fetch(.logger)
/// logger.log("Hello, World!")
/// ```
///
/// A good practice is to use a protocol in place of `T`, not a concrete type.
/// That allows you to substitute a service with a mock object for testing
/// using `Fetcher` with overrides.
public final class Service<T> {

  /// A closure that returns an instance of the service.
  public let makeService: () -> T

  /// Wraps a closure that creates an instance of the service.
  public init(_ makeService: @escaping () -> T) {
    self.makeService = makeService
  }

  /// Wraps an existing instance of the service.
  ///
  /// - Parameter service: An instance of the service.
  public convenience init(_ service: T) {
    self.init { service }
  }
}

/// The class that allows you to inject dependencies.
///
/// You create an instance of this class once and then pass it around as
/// a dependency injection container.
///
/// If you need to get a dependency, use the `fetch(_:)` method.
/// This method will create a new instance of a service using
/// the `Service.makeService` closure or the override closure (if `Fetcher`
/// was created using the `Fetcher.create()` method),
/// or will return an existing instance that was created during the previous
/// call to `fetch(_:)`
public final class Fetcher {

  private lazy var _syncQueue = DispatchQueue(
    label: "org.DependencyFetcher.DispatchQueue.\(ObjectIdentifier(self))"
  )

  private let _overrides: [ObjectIdentifier : () -> Any]

  private var _instances: [ObjectIdentifier : Any] = [:]

  fileprivate init(overrides: [ObjectIdentifier : () -> Any]) {
    _overrides = overrides
  }

  /// Creates a service of the specified kind, or returns an existing one
  /// if it was created in one of the previous calls to this method.
  ///
  /// This method is thread-safe.
  ///
  /// - Parameter service: The kind of service to create.
  /// - Returns: The service of that kind.
  public func fetch<T>(_ service: Service<T>) -> T {
    let serviceID = ObjectIdentifier(service)
    return _syncQueue.sync {
      if let service = _instances[serviceID] as? T {
        return service
      } else {
        let instance = _overrides[serviceID]?() as? T ?? service.makeService()
        _instances[serviceID] = instance
        return instance
      }
    }
  }

  /// Creates a default instance of `Fetcher` that uses `Service.makeService`
  /// closures to get a service.
  ///
  /// - Returns: The fetcher.
  public static func createDefault() -> Fetcher {
    return Fetcher(overrides: [:])
  }

  /// Allows you to add overrides for `Service.makeService` closures when
  /// fetching a service using the `fetch(_:)` method.
  ///
  /// Use the `Fetcher.Builder` instance to add the desired overrides.
  ///
  /// - Returns: A builder instance.
  public static func create() -> Builder {
    return Builder()
  }
}

extension Fetcher {

  /// A helper class that is used to create a fetcher with the needed overrides.
  /// You can add multiple overrides for the needed `Service`s.
  public final class Builder {

    fileprivate var overrides: [ObjectIdentifier : () -> Any] = [:]

    fileprivate init() {}

    /// Adds a closure that returns a service of the specified kind to
    /// the `Fetcher`'s dictionary of overrides.
    ///
    /// A `Fetcher` with overrides will use the provided closure to get
    /// an instance of a service instead of the default closure
    /// `service.makeService`.
    ///
    /// You can chain calls to this method:
    ///
    /// ```swift
    /// let fetcher
    ///   .create()
    ///   .addOverride(for: Service.logger, makeService: createMockLogger)
    ///   .addOverride(for: Service.database, makeService: createMockDatabase)
    ///   .done()
    /// ```
    ///
    /// - Parameters:
    ///   - service: The service whose creation strategy we're overriding.
    ///   - makeService: The new creation strategy.
    /// - Returns: The same instance this method is called on.
    public func addOverride<T>(for service: Service<T>,
                               makeService: @escaping () -> T) -> Builder {
      overrides[ObjectIdentifier(service)] = makeService
      return self
    }

    /// Adds a closure that returns a service of the specified kind to
    /// the `Fetcher`'s dictionary of overrides.
    ///
    /// A `Fetcher` with overrides will use the provided instance of a service
    /// instead of invoking the default closure `service.makeService`.
    ///
    /// You can chain calls to this method:
    ///
    /// ```swift
    /// let fetcher
    ///   .create()
    ///   .addOverride(for: Service.logger, instance: MockLogger())
    ///   .addOverride(for: Service.database, instance: MockDatabase())
    ///   .done()
    /// ```
    ///
    /// - Parameters:
    ///   - service: The service whose instance strategy we're substituting.
    ///   - instance: The new instance.
    /// - Returns: The same instance this method is called on.
    public func addOverride<T>(for service: Service<T>,
                               instance: T) -> Builder {
      return addOverride(for: service, makeService: { instance })
    }

    /// Creates a `Fetcher` with the specified overrides.
    ///
    /// If called multiple times, a new instance will be returned every time.
    ///
    /// - Returns: A `Fetcher` with the specified overrides.
    public func done() -> Fetcher {
      return Fetcher(overrides: overrides)
    }
  }
}
