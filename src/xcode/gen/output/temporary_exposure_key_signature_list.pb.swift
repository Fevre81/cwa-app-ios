// DO NOT EDIT.
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: temporary_exposure_key_signature_list.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

/// https://static.googleusercontent.com/media/www.google.com/en//covid19/exposurenotifications/pdfs/Exposure-Key-File-Format-and-Verification.pdf

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
private struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
    struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
    typealias Version = _2
}

struct SAP_TEKSignatureList {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    var signatures: [SAP_TEKSignature] = []

    var unknownFields = SwiftProtobuf.UnknownStorage()

    init() {}
}

struct SAP_TEKSignature {
    // SwiftProtobuf.Message conformance is added in an extension below. See the
    // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
    // methods supported on all messages.

    /// Info about the signing key, version, algorithm, etc
    var signatureInfo: SAP_SignatureInfo {
        get { return _signatureInfo ?? SAP_SignatureInfo() }
        set { _signatureInfo = newValue }
    }

    /// Returns true if `signatureInfo` has been explicitly set.
    var hasSignatureInfo: Bool { return self._signatureInfo != nil }
    /// Clears the value of `signatureInfo`. Subsequent reads from it will return its default value.
    mutating func clearSignatureInfo() { _signatureInfo = nil }

    /// E.g., File 2 in batch size of 10. Ordinal, 1-based numbering.
    /// E.g., Batch 2 of 10
    var batchNum: Int32 {
        get { return _batchNum ?? 0 }
        set { _batchNum = newValue }
    }

    /// Returns true if `batchNum` has been explicitly set.
    var hasBatchNum: Bool { return self._batchNum != nil }
    /// Clears the value of `batchNum`. Subsequent reads from it will return its default value.
    mutating func clearBatchNum() { _batchNum = nil }

    var batchSize: Int32 {
        get { return _batchSize ?? 0 }
        set { _batchSize = newValue }
    }

    /// Returns true if `batchSize` has been explicitly set.
    var hasBatchSize: Bool { return self._batchSize != nil }
    /// Clears the value of `batchSize`. Subsequent reads from it will return its default value.
    mutating func clearBatchSize() { _batchSize = nil }

    /// Signature in X9.62 format (ASN.1 SEQUENCE of two INTEGER fields)
    var signature: Data {
        get { return _signature ?? SwiftProtobuf.Internal.emptyData }
        set { _signature = newValue }
    }

    /// Returns true if `signature` has been explicitly set.
    var hasSignature: Bool { return self._signature != nil }
    /// Clears the value of `signature`. Subsequent reads from it will return its default value.
    mutating func clearSignature() { _signature = nil }

    var unknownFields = SwiftProtobuf.UnknownStorage()

    init() {}

    fileprivate var _signatureInfo: SAP_SignatureInfo?
    fileprivate var _batchNum: Int32?
    fileprivate var _batchSize: Int32?
    fileprivate var _signature: Data?
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

private let _protobuf_package = "SAP"

extension SAP_TEKSignatureList: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
    static let protoMessageName: String = _protobuf_package + ".TEKSignatureList"
    static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .same(proto: "signatures"),
    ]

    mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            switch fieldNumber {
            case 1: try decoder.decodeRepeatedMessageField(value: &signatures)
            default: break
            }
        }
    }

    func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
        if !signatures.isEmpty {
            try visitor.visitRepeatedMessageField(value: signatures, fieldNumber: 1)
        }
        try unknownFields.traverse(visitor: &visitor)
    }

    static func == (lhs: SAP_TEKSignatureList, rhs: SAP_TEKSignatureList) -> Bool {
        if lhs.signatures != rhs.signatures { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}

extension SAP_TEKSignature: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
    static let protoMessageName: String = _protobuf_package + ".TEKSignature"
    static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
        1: .standard(proto: "signature_info"),
        2: .standard(proto: "batch_num"),
        3: .standard(proto: "batch_size"),
        4: .same(proto: "signature"),
    ]

    mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
        while let fieldNumber = try decoder.nextFieldNumber() {
            switch fieldNumber {
            case 1: try decoder.decodeSingularMessageField(value: &_signatureInfo)
            case 2: try decoder.decodeSingularInt32Field(value: &_batchNum)
            case 3: try decoder.decodeSingularInt32Field(value: &_batchSize)
            case 4: try decoder.decodeSingularBytesField(value: &_signature)
            default: break
            }
        }
    }

    func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
        if let v = _signatureInfo {
            try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
        }
        if let v = _batchNum {
            try visitor.visitSingularInt32Field(value: v, fieldNumber: 2)
        }
        if let v = _batchSize {
            try visitor.visitSingularInt32Field(value: v, fieldNumber: 3)
        }
        if let v = _signature {
            try visitor.visitSingularBytesField(value: v, fieldNumber: 4)
        }
        try unknownFields.traverse(visitor: &visitor)
    }

    static func == (lhs: SAP_TEKSignature, rhs: SAP_TEKSignature) -> Bool {
        if lhs._signatureInfo != rhs._signatureInfo { return false }
        if lhs._batchNum != rhs._batchNum { return false }
        if lhs._batchSize != rhs._batchSize { return false }
        if lhs._signature != rhs._signature { return false }
        if lhs.unknownFields != rhs.unknownFields { return false }
        return true
    }
}
