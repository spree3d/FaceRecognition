//
//  Resolver+Ext.swift
//  FaceRecognition
//
//  Created by Gustavo Halperin on 6/17/22.
//

import SwiftUI
import Resolver

@propertyWrapper public struct InjectedState<Service>: DynamicProperty where Service: ObservableObject {
    @State private var service: Service
    public init() {
        self._service = State(wrappedValue: Resolver.resolve(Service.self))
    }
    public init(name: Resolver.Name? = nil, container: Resolver? = nil) {
        self._service = State(wrappedValue: container?.resolve(Service.self, name: name) ?? Resolver.resolve(Service.self, name: name))
    }
    public var wrappedValue: Service {
        get { return service }
    }
    public var projectedValue: Binding<Service> {
        return self.$service
    }
}

@propertyWrapper public struct InjectedStateObject<Service>: DynamicProperty where Service: ObservableObject {
    @StateObject private var service: Service
    public init() {
        self._service = StateObject(wrappedValue: Resolver.resolve(Service.self))
    }
    public init(name: Resolver.Name? = nil, container: Resolver? = nil) {
        self._service = StateObject(wrappedValue: container?.resolve(Service.self, name: name) ?? Resolver.resolve(Service.self, name: name))
    }
    public var wrappedValue: Service {
        get { return service }
    }
    public var projectedValue: ObservedObject<Service>.Wrapper {
        return self.$service
    }
}
