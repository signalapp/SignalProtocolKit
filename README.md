# AxolotlKit [![Build Status](https://travis-ci.org/WhisperSystems/AxolotlKit.svg?branch=master)](https://travis-ci.org/WhisperSystems/AxolotlKit)

AxolotlKit is a free (as in Freedom) implementation of the Axolotl protocol, written in Objective-C.

![AxolotlKit](http://cl.ly/WYR4/68747470733a2f2f662e636c6f75642e6769746875622e636f6d2f6173736574732f373635392f323131353834382f36303637346365322d393035632d313165332d396233622d6634663830613766363533342e706e67.png)

## Documentation

Browse the [API reference](http://cocoadocs.org/docsets/AxolotlKit/) on CocoaDocs.

### Status

Axolotl is currently being reviewed. All scrutiny welcome. Once ready, it will be distributed via CocoaPods. 

## Goal

AxolotlKit was designed to be a drop-in library that can be easily integrated into existing projects. 

Axolotl is an [asynchronous cryptographic ratcheting protocol](https://github.com/trevp/axolotl/wiki) [with interesting properties](https://github.com/WhisperSystems/TextSecure/wiki/ProtocolV2).

## Integration

AxolotlKit was designed with enough abstraction to integrate it easily into your own project. Please refer to the documentation or the TextSecure example to properly implement the required Objective-C storage protocols. 

Unlike OTR, Axolotl is designed for long-lived sessions, keys need to be stored. AxolotlKit defines interfaces of the storage classes (`IdentityKeyStore.h`, `PreKeyStore.h`, `SessionStore.h` and `SignedPreKeyStore.h`). AxolotlKit objects do comply to `NSSecureCoding` so serialization of objects for the database is provided for you.

### Prekeys

A concept of *PreKeys* are used to achieve asynchronous perfect forward secrecy. PreKeys are composed of a Curve25519 public key and a unique ID, both stored by the server.

At install time, clients generate a single signed PreKey as well as a large list of unsigned PreKeys and transmit those to the server. 


### Sessions

The Axolotl protocol is session-oriented.  Clients establish a "session," which is then used for all subsequent encrypt/decrypt operations.  There is no need to ever tear down a session once one has been established.

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

## FAQ

### Q: Will you release a Swift implementation of AxolotlKit too?
A: If Swift ends up being a good language for cryptographic applications, that will be considered. It’s still too early to make that call now. 

## Credit

Thanks to Trevor Perrin and Moxie Marlinspike for the amazing work on the Axolotl protocol and original implementation. Thanks to [Conor Heelan](http://www.conorheelan.com/) for the Axolotl illustration.
