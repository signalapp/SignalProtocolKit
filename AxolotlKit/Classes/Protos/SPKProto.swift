//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

import Foundation

// WARNING: This code is generated. Only edit within the markers.

public enum SPKProtoError: Error {
    case invalidProtobuf(description: String)
}

// MARK: - SPKProtoTSProtoWhisperMessage

@objc public class SPKProtoTSProtoWhisperMessage: NSObject {

    // MARK: - SPKProtoTSProtoWhisperMessageBuilder

    @objc public class func builder(ratchetKey: Data, counter: UInt32, ciphertext: Data) -> SPKProtoTSProtoWhisperMessageBuilder {
        return SPKProtoTSProtoWhisperMessageBuilder(ratchetKey: ratchetKey, counter: counter, ciphertext: ciphertext)
    }

    @objc public class SPKProtoTSProtoWhisperMessageBuilder: NSObject {

        private var proto = SPKProtos_TSProtoWhisperMessage()

        @objc fileprivate override init() {}

        @objc fileprivate init(ratchetKey: Data, counter: UInt32, ciphertext: Data) {
            super.init()

            setRatchetKey(ratchetKey)
            setCounter(counter)
            setCiphertext(ciphertext)
        }

        @objc public func setRatchetKey(_ valueParam: Data) {
            proto.ratchetKey = valueParam
        }

        @objc public func setCounter(_ valueParam: UInt32) {
            proto.counter = valueParam
        }

        @objc public func setPreviousCounter(_ valueParam: UInt32) {
            proto.previousCounter = valueParam
        }

        @objc public func setCiphertext(_ valueParam: Data) {
            proto.ciphertext = valueParam
        }

        @objc public func build() throws -> SPKProtoTSProtoWhisperMessage {
            return try SPKProtoTSProtoWhisperMessage.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SPKProtoTSProtoWhisperMessage.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SPKProtos_TSProtoWhisperMessage

    @objc public let ratchetKey: Data

    @objc public let counter: UInt32

    @objc public let ciphertext: Data

    @objc public var previousCounter: UInt32 {
        return proto.previousCounter
    }
    @objc public var hasPreviousCounter: Bool {
        return proto.hasPreviousCounter
    }

    private init(proto: SPKProtos_TSProtoWhisperMessage,
                 ratchetKey: Data,
                 counter: UInt32,
                 ciphertext: Data) {
        self.proto = proto
        self.ratchetKey = ratchetKey
        self.counter = counter
        self.ciphertext = ciphertext
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SPKProtoTSProtoWhisperMessage {
        let proto = try SPKProtos_TSProtoWhisperMessage(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SPKProtos_TSProtoWhisperMessage) throws -> SPKProtoTSProtoWhisperMessage {
        guard proto.hasRatchetKey else {
            throw SPKProtoError.invalidProtobuf(description: "\(logTag) missing required field: ratchetKey")
        }
        let ratchetKey = proto.ratchetKey

        guard proto.hasCounter else {
            throw SPKProtoError.invalidProtobuf(description: "\(logTag) missing required field: counter")
        }
        let counter = proto.counter

        guard proto.hasCiphertext else {
            throw SPKProtoError.invalidProtobuf(description: "\(logTag) missing required field: ciphertext")
        }
        let ciphertext = proto.ciphertext

        // MARK: - Begin Validation Logic for SPKProtoTSProtoWhisperMessage -

        // MARK: - End Validation Logic for SPKProtoTSProtoWhisperMessage -

        let result = SPKProtoTSProtoWhisperMessage(proto: proto,
                                                   ratchetKey: ratchetKey,
                                                   counter: counter,
                                                   ciphertext: ciphertext)
        return result
    }
}

#if DEBUG

extension SPKProtoTSProtoWhisperMessage {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SPKProtoTSProtoWhisperMessage.SPKProtoTSProtoWhisperMessageBuilder {
    @objc public func buildIgnoringErrors() -> SPKProtoTSProtoWhisperMessage? {
        return try! self.build()
    }
}

#endif

// MARK: - SPKProtoTSProtoPreKeyWhisperMessage

@objc public class SPKProtoTSProtoPreKeyWhisperMessage: NSObject {

    // MARK: - SPKProtoTSProtoPreKeyWhisperMessageBuilder

    @objc public class func builder(signedPreKeyID: UInt32, baseKey: Data, identityKey: Data, message: Data) -> SPKProtoTSProtoPreKeyWhisperMessageBuilder {
        return SPKProtoTSProtoPreKeyWhisperMessageBuilder(signedPreKeyID: signedPreKeyID, baseKey: baseKey, identityKey: identityKey, message: message)
    }

    @objc public class SPKProtoTSProtoPreKeyWhisperMessageBuilder: NSObject {

        private var proto = SPKProtos_TSProtoPreKeyWhisperMessage()

        @objc fileprivate override init() {}

        @objc fileprivate init(signedPreKeyID: UInt32, baseKey: Data, identityKey: Data, message: Data) {
            super.init()

            setSignedPreKeyID(signedPreKeyID)
            setBaseKey(baseKey)
            setIdentityKey(identityKey)
            setMessage(message)
        }

        @objc public func setRegistrationID(_ valueParam: UInt32) {
            proto.registrationID = valueParam
        }

        @objc public func setPreKeyID(_ valueParam: UInt32) {
            proto.preKeyID = valueParam
        }

        @objc public func setSignedPreKeyID(_ valueParam: UInt32) {
            proto.signedPreKeyID = valueParam
        }

        @objc public func setBaseKey(_ valueParam: Data) {
            proto.baseKey = valueParam
        }

        @objc public func setIdentityKey(_ valueParam: Data) {
            proto.identityKey = valueParam
        }

        @objc public func setMessage(_ valueParam: Data) {
            proto.message = valueParam
        }

        @objc public func build() throws -> SPKProtoTSProtoPreKeyWhisperMessage {
            return try SPKProtoTSProtoPreKeyWhisperMessage.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SPKProtoTSProtoPreKeyWhisperMessage.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SPKProtos_TSProtoPreKeyWhisperMessage

    @objc public let signedPreKeyID: UInt32

    @objc public let baseKey: Data

    @objc public let identityKey: Data

    @objc public let message: Data

    @objc public var registrationID: UInt32 {
        return proto.registrationID
    }
    @objc public var hasRegistrationID: Bool {
        return proto.hasRegistrationID
    }

    @objc public var preKeyID: UInt32 {
        return proto.preKeyID
    }
    @objc public var hasPreKeyID: Bool {
        return proto.hasPreKeyID
    }

    private init(proto: SPKProtos_TSProtoPreKeyWhisperMessage,
                 signedPreKeyID: UInt32,
                 baseKey: Data,
                 identityKey: Data,
                 message: Data) {
        self.proto = proto
        self.signedPreKeyID = signedPreKeyID
        self.baseKey = baseKey
        self.identityKey = identityKey
        self.message = message
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SPKProtoTSProtoPreKeyWhisperMessage {
        let proto = try SPKProtos_TSProtoPreKeyWhisperMessage(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SPKProtos_TSProtoPreKeyWhisperMessage) throws -> SPKProtoTSProtoPreKeyWhisperMessage {
        guard proto.hasSignedPreKeyID else {
            throw SPKProtoError.invalidProtobuf(description: "\(logTag) missing required field: signedPreKeyID")
        }
        let signedPreKeyID = proto.signedPreKeyID

        guard proto.hasBaseKey else {
            throw SPKProtoError.invalidProtobuf(description: "\(logTag) missing required field: baseKey")
        }
        let baseKey = proto.baseKey

        guard proto.hasIdentityKey else {
            throw SPKProtoError.invalidProtobuf(description: "\(logTag) missing required field: identityKey")
        }
        let identityKey = proto.identityKey

        guard proto.hasMessage else {
            throw SPKProtoError.invalidProtobuf(description: "\(logTag) missing required field: message")
        }
        let message = proto.message

        // MARK: - Begin Validation Logic for SPKProtoTSProtoPreKeyWhisperMessage -

        // MARK: - End Validation Logic for SPKProtoTSProtoPreKeyWhisperMessage -

        let result = SPKProtoTSProtoPreKeyWhisperMessage(proto: proto,
                                                         signedPreKeyID: signedPreKeyID,
                                                         baseKey: baseKey,
                                                         identityKey: identityKey,
                                                         message: message)
        return result
    }
}

#if DEBUG

extension SPKProtoTSProtoPreKeyWhisperMessage {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SPKProtoTSProtoPreKeyWhisperMessage.SPKProtoTSProtoPreKeyWhisperMessageBuilder {
    @objc public func buildIgnoringErrors() -> SPKProtoTSProtoPreKeyWhisperMessage? {
        return try! self.build()
    }
}

#endif

// MARK: - SPKProtoTSProtoKeyExchangeMessage

@objc public class SPKProtoTSProtoKeyExchangeMessage: NSObject {

    // MARK: - SPKProtoTSProtoKeyExchangeMessageBuilder

    @objc public class func builder() -> SPKProtoTSProtoKeyExchangeMessageBuilder {
        return SPKProtoTSProtoKeyExchangeMessageBuilder()
    }

    @objc public class SPKProtoTSProtoKeyExchangeMessageBuilder: NSObject {

        private var proto = SPKProtos_TSProtoKeyExchangeMessage()

        @objc fileprivate override init() {}

        @objc public func setId(_ valueParam: UInt32) {
            proto.id = valueParam
        }

        @objc public func setBaseKey(_ valueParam: Data) {
            proto.baseKey = valueParam
        }

        @objc public func setRatchetKey(_ valueParam: Data) {
            proto.ratchetKey = valueParam
        }

        @objc public func setIdentityKey(_ valueParam: Data) {
            proto.identityKey = valueParam
        }

        @objc public func setBaseKeySignature(_ valueParam: Data) {
            proto.baseKeySignature = valueParam
        }

        @objc public func build() throws -> SPKProtoTSProtoKeyExchangeMessage {
            return try SPKProtoTSProtoKeyExchangeMessage.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SPKProtoTSProtoKeyExchangeMessage.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SPKProtos_TSProtoKeyExchangeMessage

    @objc public var id: UInt32 {
        return proto.id
    }
    @objc public var hasID: Bool {
        return proto.hasID
    }

    @objc public var baseKey: Data? {
        guard proto.hasBaseKey else {
            return nil
        }
        return proto.baseKey
    }
    @objc public var hasBaseKey: Bool {
        return proto.hasBaseKey
    }

    @objc public var ratchetKey: Data? {
        guard proto.hasRatchetKey else {
            return nil
        }
        return proto.ratchetKey
    }
    @objc public var hasRatchetKey: Bool {
        return proto.hasRatchetKey
    }

    @objc public var identityKey: Data? {
        guard proto.hasIdentityKey else {
            return nil
        }
        return proto.identityKey
    }
    @objc public var hasIdentityKey: Bool {
        return proto.hasIdentityKey
    }

    @objc public var baseKeySignature: Data? {
        guard proto.hasBaseKeySignature else {
            return nil
        }
        return proto.baseKeySignature
    }
    @objc public var hasBaseKeySignature: Bool {
        return proto.hasBaseKeySignature
    }

    private init(proto: SPKProtos_TSProtoKeyExchangeMessage) {
        self.proto = proto
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SPKProtoTSProtoKeyExchangeMessage {
        let proto = try SPKProtos_TSProtoKeyExchangeMessage(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SPKProtos_TSProtoKeyExchangeMessage) throws -> SPKProtoTSProtoKeyExchangeMessage {
        // MARK: - Begin Validation Logic for SPKProtoTSProtoKeyExchangeMessage -

        // MARK: - End Validation Logic for SPKProtoTSProtoKeyExchangeMessage -

        let result = SPKProtoTSProtoKeyExchangeMessage(proto: proto)
        return result
    }
}

#if DEBUG

extension SPKProtoTSProtoKeyExchangeMessage {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SPKProtoTSProtoKeyExchangeMessage.SPKProtoTSProtoKeyExchangeMessageBuilder {
    @objc public func buildIgnoringErrors() -> SPKProtoTSProtoKeyExchangeMessage? {
        return try! self.build()
    }
}

#endif

// MARK: - SPKProtoTSProtoSenderKeyMessage

@objc public class SPKProtoTSProtoSenderKeyMessage: NSObject {

    // MARK: - SPKProtoTSProtoSenderKeyMessageBuilder

    @objc public class func builder() -> SPKProtoTSProtoSenderKeyMessageBuilder {
        return SPKProtoTSProtoSenderKeyMessageBuilder()
    }

    @objc public class SPKProtoTSProtoSenderKeyMessageBuilder: NSObject {

        private var proto = SPKProtos_TSProtoSenderKeyMessage()

        @objc fileprivate override init() {}

        @objc public func setId(_ valueParam: UInt32) {
            proto.id = valueParam
        }

        @objc public func setIteration(_ valueParam: UInt32) {
            proto.iteration = valueParam
        }

        @objc public func setCiphertext(_ valueParam: Data) {
            proto.ciphertext = valueParam
        }

        @objc public func build() throws -> SPKProtoTSProtoSenderKeyMessage {
            return try SPKProtoTSProtoSenderKeyMessage.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SPKProtoTSProtoSenderKeyMessage.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SPKProtos_TSProtoSenderKeyMessage

    @objc public var id: UInt32 {
        return proto.id
    }
    @objc public var hasID: Bool {
        return proto.hasID
    }

    @objc public var iteration: UInt32 {
        return proto.iteration
    }
    @objc public var hasIteration: Bool {
        return proto.hasIteration
    }

    @objc public var ciphertext: Data? {
        guard proto.hasCiphertext else {
            return nil
        }
        return proto.ciphertext
    }
    @objc public var hasCiphertext: Bool {
        return proto.hasCiphertext
    }

    private init(proto: SPKProtos_TSProtoSenderKeyMessage) {
        self.proto = proto
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SPKProtoTSProtoSenderKeyMessage {
        let proto = try SPKProtos_TSProtoSenderKeyMessage(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SPKProtos_TSProtoSenderKeyMessage) throws -> SPKProtoTSProtoSenderKeyMessage {
        // MARK: - Begin Validation Logic for SPKProtoTSProtoSenderKeyMessage -

        // MARK: - End Validation Logic for SPKProtoTSProtoSenderKeyMessage -

        let result = SPKProtoTSProtoSenderKeyMessage(proto: proto)
        return result
    }
}

#if DEBUG

extension SPKProtoTSProtoSenderKeyMessage {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SPKProtoTSProtoSenderKeyMessage.SPKProtoTSProtoSenderKeyMessageBuilder {
    @objc public func buildIgnoringErrors() -> SPKProtoTSProtoSenderKeyMessage? {
        return try! self.build()
    }
}

#endif

// MARK: - SPKProtoTSProtoSenderKeyDistributionMessage

@objc public class SPKProtoTSProtoSenderKeyDistributionMessage: NSObject {

    // MARK: - SPKProtoTSProtoSenderKeyDistributionMessageBuilder

    @objc public class func builder() -> SPKProtoTSProtoSenderKeyDistributionMessageBuilder {
        return SPKProtoTSProtoSenderKeyDistributionMessageBuilder()
    }

    @objc public class SPKProtoTSProtoSenderKeyDistributionMessageBuilder: NSObject {

        private var proto = SPKProtos_TSProtoSenderKeyDistributionMessage()

        @objc fileprivate override init() {}

        @objc public func setId(_ valueParam: UInt32) {
            proto.id = valueParam
        }

        @objc public func setIteration(_ valueParam: UInt32) {
            proto.iteration = valueParam
        }

        @objc public func setChainKey(_ valueParam: Data) {
            proto.chainKey = valueParam
        }

        @objc public func setSigningKey(_ valueParam: Data) {
            proto.signingKey = valueParam
        }

        @objc public func build() throws -> SPKProtoTSProtoSenderKeyDistributionMessage {
            return try SPKProtoTSProtoSenderKeyDistributionMessage.parseProto(proto)
        }

        @objc public func buildSerializedData() throws -> Data {
            return try SPKProtoTSProtoSenderKeyDistributionMessage.parseProto(proto).serializedData()
        }
    }

    fileprivate let proto: SPKProtos_TSProtoSenderKeyDistributionMessage

    @objc public var id: UInt32 {
        return proto.id
    }
    @objc public var hasID: Bool {
        return proto.hasID
    }

    @objc public var iteration: UInt32 {
        return proto.iteration
    }
    @objc public var hasIteration: Bool {
        return proto.hasIteration
    }

    @objc public var chainKey: Data? {
        guard proto.hasChainKey else {
            return nil
        }
        return proto.chainKey
    }
    @objc public var hasChainKey: Bool {
        return proto.hasChainKey
    }

    @objc public var signingKey: Data? {
        guard proto.hasSigningKey else {
            return nil
        }
        return proto.signingKey
    }
    @objc public var hasSigningKey: Bool {
        return proto.hasSigningKey
    }

    private init(proto: SPKProtos_TSProtoSenderKeyDistributionMessage) {
        self.proto = proto
    }

    @objc
    public func serializedData() throws -> Data {
        return try self.proto.serializedData()
    }

    @objc public class func parseData(_ serializedData: Data) throws -> SPKProtoTSProtoSenderKeyDistributionMessage {
        let proto = try SPKProtos_TSProtoSenderKeyDistributionMessage(serializedData: serializedData)
        return try parseProto(proto)
    }

    fileprivate class func parseProto(_ proto: SPKProtos_TSProtoSenderKeyDistributionMessage) throws -> SPKProtoTSProtoSenderKeyDistributionMessage {
        // MARK: - Begin Validation Logic for SPKProtoTSProtoSenderKeyDistributionMessage -

        // MARK: - End Validation Logic for SPKProtoTSProtoSenderKeyDistributionMessage -

        let result = SPKProtoTSProtoSenderKeyDistributionMessage(proto: proto)
        return result
    }
}

#if DEBUG

extension SPKProtoTSProtoSenderKeyDistributionMessage {
    @objc public func serializedDataIgnoringErrors() -> Data? {
        return try! self.serializedData()
    }
}

extension SPKProtoTSProtoSenderKeyDistributionMessage.SPKProtoTSProtoSenderKeyDistributionMessageBuilder {
    @objc public func buildIgnoringErrors() -> SPKProtoTSProtoSenderKeyDistributionMessage? {
        return try! self.build()
    }
}

#endif
