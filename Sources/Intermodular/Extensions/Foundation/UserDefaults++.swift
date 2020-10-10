//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension UserDefaults {
    func decode<Value: Codable>(_ type: Value.Type = Value.self, forKey key: String) throws -> Value? {
        if type is URL.Type || type is Optional<URL>.Type {
            return try decode(String.self, forKey: key).flatMap(URL.init(string:)) as? Value
        } else if let value = value(forKey: key) as? Value {
            return value
        } else if let data = value(forKey: key) as? Data {
            return try PropertyListDecoder().decode(Value.self, from: data)
        } else {
            return nil
        }
    }
    
    func encode<Value: Codable>(_ value: Value, forKey key: String) throws {
        if let value = value as? _opaque_Optional, !value.isNotNil {
            removeObject(forKey: key)
        } else if let value = value as? UserDefaultsPrimitive {
            setValue(value, forKey: key)
        } else if let value = value as? URL {
            setValue(value.path, forKey: key)
        } else {
            setValue(try PropertyListEncoder().encode(value), forKey: key)
        }
    }
}

// MARK: - Helpers-

private protocol _opaque_Optional {
    var isNotNil: Bool { get }
}

extension Optional: _opaque_Optional {
    var isNotNil: Bool {
        self != nil
    }
}

protocol UserDefaultsPrimitive {
    
}

extension Bool: UserDefaultsPrimitive {
    
}

extension Double: UserDefaultsPrimitive {
    
}

extension Float: UserDefaultsPrimitive {
    
}

extension Int: UserDefaultsPrimitive {
    
}

extension Int8: UserDefaultsPrimitive {
    
}

extension Int16: UserDefaultsPrimitive {
    
}

extension Int32: UserDefaultsPrimitive {
    
}

extension Int64: UserDefaultsPrimitive {
    
}

extension String: UserDefaultsPrimitive {
    
}

extension UInt: UserDefaultsPrimitive {
    
}

extension UInt8: UserDefaultsPrimitive {
    
}

extension UInt16: UserDefaultsPrimitive {
    
}

extension UInt32: UserDefaultsPrimitive {
    
}

extension UInt64: UserDefaultsPrimitive {
    
}
