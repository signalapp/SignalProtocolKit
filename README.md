# AxolotlKit [![Build Status](https://travis-ci.org/FredericJacobs/AxolotlKit?branch=master)](https://travis-ci.org/FredericJacobs/AxolotlKit)


AxolotlKit is a free (as in Freedom) implementation of the Axolotl protocol, written in Objective-C.

![AxolotlKit](http://cl.ly/WYR4/68747470733a2f2f662e636c6f75642e6769746875622e636f6d2f6173736574732f373635392f323131353834382f36303637346365322d393035632d313165332d396233622d6634663830613766363533342e706e67.png)

## Roadmap 

The goal of this first implementation of AxolotlKit is to have a storage-agnostic library written in Objective-C of the [Axolotl ratchet](https://github.com/trevp/axolotl/wiki). Only features of Axolotl used in the TextSecure protocol will be implemented in this initial release (header keys used in Pond won't be part of this implementation).

Because, unlike OTR, Axolotl is designed to have long-lived sessions, keys are stored in a locally encrypted database. To give as much flexibility to the developer, we do not provide an independent storage for the keys but do provide an Objective-C protocol to implement for keys to be stored.

If Swift turn out to be a great language for cryptographic applications, we will probably rewrite AxolotlKit in Swift.

## Release

AxolotlKit is going to be released as a CocoaPod as soon as it's considered stable and has gotten enough peer-review.

## Credit

Thanks to [Conor Heelan](http://www.conorheelan.com/) for the Axolotl illustration.
