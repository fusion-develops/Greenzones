local Permissions = {
    ['discord:335847483940798465'] = true
}

local function HasPermissions(source)
    local Identifiers = GetPlayerIdentifiers(source)
    for ident in pairs(Permissions) do 
        for i = 1, #Identifiers do 
            if ident == Identifiers[i] then 
                return true 
            end 
        end 
    end 

    return false
end 

local function GetTableDump(dump, indent, getTable)

    local TableDump = ''
    local TotalIndexes = 0
    local ThisIndex = 0
    local TableName = nil
    local indent = (indent or 0)
    local getTable = (getTable or true)

    if getTable then
        for Name_G, This_G in pairs(_G) do
            if type(This_G) == 'table' and This_G == dump then
                TableName = Name_G
                indent += 1
                TableDump = TableName .. ' = {\n'
                break 
            end
        end
    end

    for _ in pairs(dump) do
        TotalIndexes += 1
    end

    for k,v in pairs(dump) do
        ThisIndex += 1 
        if type(v) == 'table' then
            local TableSize = 0
            for _ in pairs(v) do
                TableSize = (TableSize + 1)
            end
            if TableSize > 0 then
                TableDump = TableDump .. string.rep('    ', indent) .. (type(k) ~= 'number' and (k .. ' = ') or '') .. '{\n'
                TableDump = TableDump .. GetTableDump(v, indent + 1, false)
                TableDump = TableDump .. string.rep('    ', indent) .. '}' .. (ThisIndex ~= TotalIndexes and ',' or '') .. '\n'
            else
                TableDump = TableDump .. string.rep('    ', indent) .. (type(k) ~= 'number' and (k .. ' = ') or '') .. '{}'    
            end
        else
            TableDump = TableDump .. string.rep('    ', indent) .. (type(k) ~= 'number' and (k .. ' = ') or '') .. (type(v) == 'string' and '\'' or '') .. tostring(v) .. (type(v) == 'string' and '\'' or '') .. (ThisIndex ~= TotalIndexes and ',' or '') .. '\n'
        end
    end

    if TableName ~= nil then
        TableDump = string.sub(TableDump, 1, #TableDump - 1) .. '\n}'
    end
    return TableDump
end

local function CreateZone(action, index)
    if HasPermissions(source) then 
        if action == 1 then 
            local type, coords, radius, debug, blip = lib.callback.await('GetData', source)
            local t = {
                type = type,
                coords = coords,
                size = radius,
                debug = debug,
                blip = blip
            }
            Zones[#Zones+1] = t
            TriggerClientEvent('Greenzone:Added', -1 , t)
            local File = io.open(GetResourcePath(GetCurrentResourceName())..'/config.lua', 'w+')
            if not File then return end 
            File:write(GetTableDump(Zones))
            File:close()
        elseif action == 2 then 
            table.remove(Zones, index)
            local File = io.open(GetResourcePath(GetCurrentResourceName())..'/config.lua', 'w+')
            if not File then return end 
            File:write(GetTableDump(Zones))
            File:close()
            Wait(50)
            TriggerClientEvent('Greenzone:Remove', -1)

        else 

        end 
    end 
end 

RegisterNetEvent('zone:settings', CreateZone)

lib.callback.register('HasPermissions', function()
    return HasPermissions(source)
end)
