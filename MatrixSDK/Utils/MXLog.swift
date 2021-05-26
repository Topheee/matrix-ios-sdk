//
// Copyright 2021 The Matrix.org Foundation C.I.C
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import SwiftyBeaver

@objc public class MXLogConfiguration: NSObject {
    @objc var logLevel: MXLogLevel = MXLogLevel.verbose
    @objc var redirectLogsToFiles: Bool = false
    @objc var logFilesSizeLimit: UInt = 100 * 1024 * 1024
    @objc var maxLogFilesCount: UInt = 50
    @objc var subLogName: String? = nil
}

@objc public enum MXLogLevel: UInt {
    case none
    case verbose
    case debug
    case info
    case warning
    case error
}

private let logger = SwiftyBeaver.self

@objc public class MXLog: NSObject {
    
    @objc static public func configure(_ configuration: MXLogConfiguration) {
        if let subLogName = configuration.subLogName {
            MXLogger.setSubLogName(subLogName)
        }
        
        MXLogger.redirectNSLog(toFiles: configuration.redirectLogsToFiles,
                               numberOfFiles: configuration.maxLogFilesCount,
                               sizeLimit: configuration.logFilesSizeLimit)
        
        guard configuration.logLevel != .none else {
            return
        }
        
        let consoleDestination = ConsoleDestination()
        consoleDestination.useNSLog = true
        
        switch configuration.logLevel {
            case .verbose:
                consoleDestination.minLevel = .verbose
            case .debug:
                consoleDestination.minLevel = .debug
            case .info:
                consoleDestination.minLevel = .info
            case .warning:
                consoleDestination.minLevel = .warning
            case .error:
                consoleDestination.minLevel = .error
            case .none:
                break
        }
        
        logger.addDestination(consoleDestination)
    }
    
    public static func verbose(_ message: @autoclosure () -> Any, _
                                file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        logger.verbose(message(), file, function, line: line, context: context)
    }
    
    @available(swift, obsoleted: 5.4)
    @objc public static func logVerbose(_ message: String, file: String, function: String, line: Int) {
        logger.verbose(message, file, function, line: line)
    }
    
    public static func debug(_ message: @autoclosure () -> Any, _
                                file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        logger.debug(message(), file, function, line: line, context: context)
    }
    
    @available(swift, obsoleted: 5.4)
    @objc public static func logDebug(_ message: String, file: String, function: String, line: Int) {
        logger.debug(message, file, function, line: line)
    }
    
    public static func info(_ message: @autoclosure () -> Any, _
                                file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        logger.info(message(), file, function, line: line, context: context)
    }
    
    @available(swift, obsoleted: 5.4)
    @objc public static func logInfo(_ message: String, file: String, function: String, line: Int) {
        logger.info(message, file, function, line: line)
    }
    
    public static func warning(_ message: @autoclosure () -> Any, _
                                file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        logger.warning(message(), file, function, line: line, context: context)
    }
    
    @available(swift, obsoleted: 5.4)
    @objc public static func logWarning(_ message: String, file: String, function: String, line: Int) {
        logger.warning(message, file, function, line: line)
    }
    
    public static func error(_ message: @autoclosure () -> Any, _
                                file: String = #file, _ function: String = #function, line: Int = #line, context: Any? = nil) {
        logger.error(message(), file, function, line: line, context: context)
    }
    
    @available(swift, obsoleted: 5.4)
    @objc public static func logError(_ message: String, file: String, function: String, line: Int) {
        logger.error(message, file, function, line: line)
    }
}
