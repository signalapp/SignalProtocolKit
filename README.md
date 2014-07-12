# AxolotlKit


Axolotl Kit is a free implementation of the Axolotl protocol

## Roadmap 

The goal of this first implementation of AxolotlKit is to have a storage-agnostic library written in Objective-C of the [Axolotl ratchet](https://github.com/trevp/axolotl/wiki). Only features of Axolotl used in the TextSecure protocol will be implemented in this initial release (header keys used in Pond won't be part of this implementation).

Because, unlike OTR, Axolotl is designed to have long-lived sessions, keys are stored in a locally encrypted database. To give as much flexibility to the developer, we do not provide an independent storage for the keys but do provide an Objective-C protocol to implement for keys to be stored.

If Swift turn out to be a great language for cryptographic applications, I will probably rewrite AxolotlKit in Swift.
