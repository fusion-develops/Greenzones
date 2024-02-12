local function createblip(coords)
    ---@diagnostic disable-next-line: missing-parameter
    local Blip = AddBlipForCoord(coords)
    SetBlipSprite(Blip, 1)
	SetBlipScale(Blip, 0.7)
	SetBlipColour(Blip, 2)
	SetBlipAsShortRange(Blip, true)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentString('Greenzone')
	EndTextCommandSetBlipName(Blip)
end 

local CreatedZones = {}

local function Update(self)
    local status = self.insideZone
    SetLocalPlayerAsGhost(status)
    if status then 
        lib.showTextUI('You Are Inside The Greenzone')
    else
        lib.hideTextUI()
    end 
end

local function CreateZone(data)
    CreatedZones[#CreatedZones+1] = lib.zones[data.type]({
        coords = data.coords,
        radius = data.type == 'sphere' and data.size or data.type == 'box' and vec3(data.size.. '.0', data.size.. '.0', data.size.. '.0'),
        onEnter = Update,
        onExit = Update,
        debug = true
    })

    return data.blip and createblip(data.coords)
end 



local function InitializeZone()
    local data = lib.inputDialog('Greenzone Creator', {
        {type = 'select', label = 'Type', options = {
            {label = 'Circle', value = 'sphere'},
            {label = 'Box', value = 'box'},
            {label = 'Poly', value = 'poly'},
        }},
        {label = 'Radius', type = 'number'},
        {label = 'Debug', type = 'checkbox'},
        {label = 'Blip', type = 'checkbox'},

    })
    if not data then return end 

    for i = 1, 4 do 
        if not data[i] then return end 
    end 
    
    return data[1], GetEntityCoords(cache.ped), tonumber(data[2]), data[3], data[4]
end 

lib.callback.register('GetData', InitializeZone)
RegisterNetEvent('Greenzone:Added', CreateZone)

for i = 1, #Zones do 
    CreateZone(Zones[i])
end 

local function OpenEditMenu(id)
    lib.registerMenu({
        id = 'edit',
        title = 'Greenzones',
        onClose = function()
            lib.showMenu('Greenzones')
        end, 
        options = {
            {label = 'Teleport', close = false},
            {label = 'Delete Zone'},
        }
        
    }, function (selected)
        if selected == 1 then 
            SetEntityCoords(cache.ped, Zones[id].coords)
        else
            TriggerServerEvent('zone:settings', 2, id)
        end 
    end)

    lib.showMenu('edit')
end 


lib.registerMenu({
    id = 'Greenzones',
    title = 'Greenzones',
    options = {
        {label = 'Create Zone'},
        {label = 'Delete Zone'},
        {label = 'Create Zone'},
    }
    
}, function (selected)
    if selected == 1 then 
        TriggerServerEvent('zone:settings', 1)
    elseif selected == 2 then 
        local options = {}
        for i = 1, #Zones do 
            local data = Zones[i]
            options[i] = {
                label = 'Greenzone: '.. data.coords,
            }
        end
        
        lib.registerMenu({
            id = 'Teleport Options',
            title = 'Greenzones',
            options = options,
            onClose = function()
                lib.showMenu('Greenzones')
            end, 
        }, function (selected)
            OpenEditMenu(selected)
        end)
        lib.showMenu('Teleport Options')
    end 
end)

RegisterNetEvent('Greenzone:Remove', function ()
    for i = 1, #CreatedZones do
        CreatedZones[i]:remove()
    end 

    for i = 1, #Zones do 
        CreateZone(Zones[i])
    end 
end)

local function OpenMenu()
    if not lib.callback.await('HasPermissions', false) then return end 
    lib.showMenu('Greenzones')
end 

RegisterCommand('greenzones', OpenMenu)