//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

import Foundation

    public enum DataParserError : Error { case overflow(description : String) }

// MARK: - DataParser

@objc public class DataParser : NSObject {

    fileprivate static let logTag = "DataParser" fileprivate let logTag = "DataParser"

        private let data : Data private var cursor : Int
                                                     = 0

                                                     @objc public init(data
                                                                       : Data)
    {
        self.data = data
    }

    @objc public func nextData(length : Int) throws->Data
    {
        guard cursor + length
            <= data.count else { throw DataParserError.overflow(description
                                                                : "\(logTag) invalid data read") } let endIndex
            = cursor + length let result = data.subdata(in
                                                        : cursor..< endIndex) cursor
            += length return result
    }
}
