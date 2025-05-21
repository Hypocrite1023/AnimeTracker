//
//  Publisher+Ext.swift
//  AnimeTracker
//
//  Created by YI-CHUN CHIU on 2025/5/15.
//
import Combine

extension AnyPublisher {
    static var empty: AnyPublisher<Output, Failure> {
        return Empty().eraseToAnyPublisher()
    }
}
