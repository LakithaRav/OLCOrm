# OLCOrm

[![CI Status](http://img.shields.io/travis/Lakitha Samarasinghe/OLCOrm.svg?style=flat)](https://travis-ci.org/Lakitha Samarasinghe/OLCOrm)
[![Version](https://img.shields.io/cocoapods/v/OLCOrm.svg?style=flat)](http://cocoadocs.org/docsets/OLCOrm)
[![License](https://img.shields.io/cocoapods/l/OLCOrm.svg?style=flat)](http://cocoadocs.org/docsets/OLCOrm)
[![Platform](https://img.shields.io/cocoapods/p/OLCOrm.svg?style=flat)](http://cocoadocs.org/docsets/OLCOrm)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Dependencies

FMDB - https://github.com/ccgus/fmdb
    pod "OLCOrm"

## Installation

OLCOrm is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "OLCOrm"
    
## Special Thanks

Special thanks goes to 'ccgus' for the awesome FMDB database warpper library. And to 'kevinejohn' for his NSObject-KJSerializer (https://github.com/kevinejohn/NSObject-KJSerializer) utlity class.

## Note

We all know the working with Core Data is major pain in the neck. Yet it is in a way bit easy you work with, if you get an hold of how it actaully work, working with only model calsses to update the database structre on the fly.

And for those who hate to use Core Data, FMDB is you best choice. But still it lack the capability of mapping objects to models. So you  have to manullay create the databas and queries, ah.

So I develop this Libaray as an wrapper library to FMDB, that handle the database, table & all other CRUD function that we use daily. To make you life easire.

This libaray is still at it early stages (not even Alpha) so you are always welcome to teak thigs here and there to make this better :).
                       
Happy Coding.

## Author

Lakitha Samarasinghe, lakitha@fidenz.com

## License

OLCOrm is available under the MIT license. See the LICENSE file for more info.

