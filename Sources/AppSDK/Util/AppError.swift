//
//  AppError.swift
//  AppSDK
//
//  Created by Joe Manto on 12/18/25.
//

import Foundation

public enum AppError: LocalizedError {
    case networkFailure(underlying: Error?)
    case decodingFailure(underlying: Error?)
    case internalFailure(_ message: String)
    case invalidInput(_ message: String)
    case invalidOperation(_ message: String)
    case unauthorized
    case notFound(resource: String?, _ message: String = "")
    case serverError(statusCode: Int? = nil, message: String = "")

    public var description: String {
        switch self {
        case .networkFailure(let underlying):
            "Network Failure: \(underlying)"
        case .decodingFailure(let underlying):
            "Decoding Failure: \(underlying)"
        case .internalFailure(let message):
            "Internal Failure: \(message)"
        case .invalidInput(let message):
            "Invalid Input: \(message)"
        case .invalidOperation(let message):
            "Invalid Operation: \(message)"
        case .unauthorized:
            "Unauthorized"
        case .notFound(let resource, let message):
            "\(resource) Not Found \(!message.isEmpty ? ": \(message)" : "")"
        case .serverError(let statusCode, let message):
            "Server Error: \(statusCode ?? 500), \(message)"
        }
    }
}
