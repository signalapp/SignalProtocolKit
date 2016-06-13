**Deprecation Warning**: It is recommended that [libsignal-protocol-c](https://github.com/whispersystems/libsignal-protocol-c) be used for all new applications.


# SignalProtocolKit [![Build Status](https://travis-ci.org/WhisperSystems/AxolotlKit.svg?branch=master)](https://travis-ci.org/WhisperSystems/AxolotlKit)

SignalProtocolKit is an implementation of the Signal protocol, written in Objective-C.

## Documentation

Browse the [API reference](http://cocoadocs.org/docsets/AxolotlKit/) on CocoaDocs.

## Goal

SignalProtocolKit was designed to be a drop-in library that can be easily integrated into existing projects. 

The Signal protocol is an [asynchronous cryptographic ratcheting protocol](https://whispersystems.org/blog/advanced-ratcheting/) [with interesting properties](https://whispersystems.org/blog/asynchronous-security/).

## Integration

SignalProtocolKit was designed with enough abstraction to integrate it easily into your own project. Please refer to the documentation or the Signal example to properly implement the required Objective-C storage protocols. 

Signal Protocol is designed for long-lived sessions, keys need to be stored. SignalProtocolKit defines interfaces of the storage classes (`IdentityKeyStore.h`, `PreKeyStore.h`, `SessionStore.h` and `SignedPreKeyStore.h`). SignalProtocolKit objects do comply to `NSSecureCoding` so serialization of objects for the database is provided for you.

### Prekeys

A concept of *PreKeys* are used to achieve asynchronous perfect forward secrecy. PreKeys are composed of a Curve25519 public key and a unique ID, both stored by the server.

At install time, clients generate a single signed PreKey as well as a large list of unsigned PreKeys and transmit those to the server. 


### Sessions

The Signal protocol is session-oriented.  Clients establish a "session," which is then used for all subsequent encrypt/decrypt operations.  There is no need to ever tear down a session once one has been established.

Sessions are established in one of these ways:

- PreKeyBundles. A client that wishes to send a message to a recipient can establish a session by retrieving a PreKeyBundle for that recipient from the server.

- PreKeyWhisperMessages. A client can receive a PreKeyWhisperMessage from a recipient and use it to establish a session.

### State

An established session encapsulates a lot of state between two clients.  That state is maintained in durable records which need to be kept for the life of the session.

State is kept in the following places:

- Identity State.  Clients will need to maintain the state of their own identity key pair, as well as identity public keys received from other clients.

- PreKey State. Clients will need to maintain the state of their generated (private) PreKeys.

- Signed PreKey States. Clients will need to maintain the state of the their signed (private) PreKeys.

- Session State.  Clients will need to maintain the state of the sessions they have established.

