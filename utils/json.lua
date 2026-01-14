-- Simple JSON encoder/decoder for Solar2D
-- This is a basic implementation; for production, consider using a more robust library

local json = {}

-- Encode a Lua table to JSON string
function json.encode( data )
    local function encodeValue( value )
        local valueType = type( value )
        
        if valueType == "nil" then
            return "null"
        elseif valueType == "boolean" then
            return value and "true" or "false"
        elseif valueType == "number" then
            return tostring( value )
        elseif valueType == "string" then
            return '"' .. string.gsub( value, '"', '\\"' ) .. '"'
        elseif valueType == "table" then
            local isArray = true
            local maxIndex = 0
            for k, v in pairs( value ) do
                if type( k ) ~= "number" then
                    isArray = false
                    break
                end
                if k > maxIndex then
                    maxIndex = k
                end
            end
            
            if isArray then
                local result = {}
                for i = 1, maxIndex do
                    result[#result + 1] = encodeValue( value[i] )
                end
                return "[" .. table.concat( result, "," ) .. "]"
            else
                local result = {}
                for k, v in pairs( value ) do
                    result[#result + 1] = '"' .. tostring( k ) .. '":' .. encodeValue( v )
                end
                return "{" .. table.concat( result, "," ) .. "}"
            end
        else
            return "null"
        end
    end
    
    return encodeValue( data )
end

-- Decode a JSON string to Lua table
function json.decode( jsonString )
    if not jsonString or jsonString == "" then
        return nil
    end
    
    -- Simple parser (for production, use a proper JSON library)
    -- This is a basic implementation
    local function parseValue( str, pos )
        pos = pos or 1
        while pos <= #str and string.match( str:sub( pos, pos ), "%s" ) do
            pos = pos + 1
        end
        
        if pos > #str then return nil, pos end
        
        local char = str:sub( pos, pos )
        
        if char == "{" then
            -- Parse object
            pos = pos + 1
            local obj = {}
            while pos <= #str do
                while pos <= #str and string.match( str:sub( pos, pos ), "%s" ) do
                    pos = pos + 1
                end
                if str:sub( pos, pos ) == "}" then
                    pos = pos + 1
                    break
                end
                -- Parse key
                local key, newPos = parseValue( str, pos )
                pos = newPos
                while pos <= #str and string.match( str:sub( pos, pos ), "%s" ) or str:sub( pos, pos ) == ":" do
                    pos = pos + 1
                end
                -- Parse value
                local value, newPos = parseValue( str, pos )
                obj[key] = value
                pos = newPos
                while pos <= #str and ( string.match( str:sub( pos, pos ), "%s" ) or str:sub( pos, pos ) == "," ) do
                    pos = pos + 1
                end
            end
            return obj, pos
        elseif char == "[" then
            -- Parse array
            pos = pos + 1
            local arr = {}
            local index = 1
            while pos <= #str do
                while pos <= #str and string.match( str:sub( pos, pos ), "%s" ) do
                    pos = pos + 1
                end
                if str:sub( pos, pos ) == "]" then
                    pos = pos + 1
                    break
                end
                local value, newPos = parseValue( str, pos )
                arr[index] = value
                index = index + 1
                pos = newPos
                while pos <= #str and ( string.match( str:sub( pos, pos ), "%s" ) or str:sub( pos, pos ) == "," ) do
                    pos = pos + 1
                end
            end
            return arr, pos
        elseif char == '"' then
            -- Parse string
            pos = pos + 1
            local start = pos
            while pos <= #str and str:sub( pos, pos ) ~= '"' do
                if str:sub( pos, pos ) == "\\" then
                    pos = pos + 1
                end
                pos = pos + 1
            end
            local value = str:sub( start, pos - 1 )
            pos = pos + 1
            return value, pos
        elseif string.match( char, "%d" ) or char == "-" then
            -- Parse number
            local start = pos
            if char == "-" then pos = pos + 1 end
            while pos <= #str and string.match( str:sub( pos, pos ), "%d" ) do
                pos = pos + 1
            end
            if pos <= #str and str:sub( pos, pos ) == "." then
                pos = pos + 1
                while pos <= #str and string.match( str:sub( pos, pos ), "%d" ) do
                    pos = pos + 1
                end
            end
            local value = tonumber( str:sub( start, pos - 1 ) )
            return value, pos
        elseif str:sub( pos, pos + 3 ) == "true" then
            return true, pos + 4
        elseif str:sub( pos, pos + 4 ) == "false" then
            return false, pos + 5
        elseif str:sub( pos, pos + 3 ) == "null" then
            return nil, pos + 4
        end
        return nil, pos
    end
    
    local result, pos = parseValue( jsonString )
    return result
end

return json
