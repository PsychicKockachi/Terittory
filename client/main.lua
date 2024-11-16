ESX = exports["es_extended"]:getSharedObject()
lib.locale()
local BogStarted = false
local zoneData = {}
local Capturetime = 0 or nil
local OuterZone, CaptureZone = nil, nil

AddEventHandler('esx:onPlayerDeath', function(data) --ESX
    data.victim = source
    local victimcoords = data.victimCoords
    local playerPed = data.victim
    if BogStarted then
        local isinsideZone = OuterZone:contains(vec3(victimcoords.x, victimcoords.y, victimcoords.z))
        if isinsideZone then
            PlayerKilledByPlayer(data, killerServerId, data.killerClientId, data.deathCause)
            DoScreenFadeOut(800)
            Wait(3000)
            RespawnPed(playerPed, Config.Spawnlocation, 0.0)
            Wait(100)
            TriggerEvent('esx_ambulancejob:revive')
            while not IsScreenFadedOut() do
                Wait(50)
            end
            DoScreenFadeIn(5000)
        else
            return
        end
    end
end)

RegisterCommand('startzone', function()
    if not BogStarted then
        OpenMenu()
    else
        lib.notify({
            id = 'error_ontification',
            title = 'SY_Bog',
            description = locale('cant_startzone'),
            position = 'top',
            duration = '3500',
            style = {
                backgroundColor = '#141517',
                color = '#C1C2C5',
                ['.description'] = {
                    color = '#909296'
                }
            },
            icon = 'xmark',
            iconColor = '#C53030'
        })
    end
end)

RegisterCommand('stopzone', function()
    if BogStarted then
        RemoveZones()
        BogStarted = false
        zoneData = {}
        -- Capturetime = 0 or nil
        -- OuterZone, CaptureZone = nil, nil
    end
end)

function OpenMenu()
    local zoneNames = {}
    for k, v in pairs(Config.Zones) do
        table.insert(zoneData, v)

        table.insert(zoneNames, { value = v.name })
    end


    lib.callback('SY_Bog:server:getjobs', false, function(data)
        if not data then return end
        local jobs_table = data.input_table
        if not data.isaJob then
            lib.notify({
                id = 'error_ontification',
                title = 'SY_Bog',
                description = locale('no_job'),
                position = 'top',
                duration = 3500,
                style = {
                    backgroundColor = '#141517',
                    color = '#C1C2C5',
                    ['.description'] = {
                        color = '#909296'
                    }
                },
                icon = 'xmark',
                iconColor = '#C53030'
            })
            return
        end

        -- input
        local input = lib.inputDialog('Start Zone', {
            {
                type = 'select',
                label = 'Select zone',
                options = zoneNames,
                description = 'Some input description',
                required = true,
            },
            {
                type = 'select',
                label = 'Select attacker',
                options = jobs_table,
                description = 'Select the attacker',
                required = true,
            },
            {
                type = 'select',
                label = 'Select defender',
                options = jobs_table,
                description = 'Select the defender',
                required = true,
            },
        })



        if input then
            local selectedZone = input[1]
            if input[2] == input[3] then
                lib.notify({
                    id = 'error_ontification',
                    title = 'SY_Bog',
                    description = locale('no_same_input'),
                    position = 'top',
                    duration = 3500,
                    style = {
                        backgroundColor = '#141517',
                        color = '#C1C2C5',
                        ['.description'] = {
                            color = '#909296'
                        }
                    },
                    icon = 'xmark',
                    iconColor = '#C53030'
                })
                return
            end

            for _, zone in pairs(zoneData) do
                if selectedZone == zone.name then
                    TriggerServerEvent('SY_Bog:server:startOuterZone', zone)
                end
            end
        end
    end)
end

RegisterNetEvent('SY_Bog:client:startOuterZone')
AddEventHandler('SY_Bog:client:startOuterZone', function(data)
    BogStarted = true
    CreateZone(data)
    startCaptureZone(data)
    TriggerEvent('chat:addMessage', {
        template = '<div class="chat-message turf"><i class="fas fa-door-open"></i> <b><span style="color: #ffffff">[Turf Manager] {0}</span>&nbsp;<span style="font-size: 14px; color: #e1e1e1;">{2}</span></b><div style="margin-top: 5px; font-weight: 300;">{1}</div></div>',
        args = {'', 'BOTH TEAM BE READY BOG IS STARTING!!', 1 }
    })
    Citizen.Wait(10000)
    TriggerEvent('chat:addMessage', {
        template = '<div class="chat-message turf"><i class="fas fa-door-open"></i> <b><span style="color: #7d7d7d">[Turf Manager] {0}</span>&nbsp;<span style="font-size: 14px; color: #e1e1e1;">{2}</span></b><div style="margin-top: 5px; font-weight: 300;">{1}</div></div>',
        args = {'', 'BOG STARTED', 1 }
    }) ----------this will send a message in chat that bog has started
    TriggerEvent('sy_announce:display', -1, 'WELCOME', 'A new player is connecting!', 5000)
    print('started timer') -------------just a debug
    exports['opr_countdownv2']:run(45) -----------started timer
    print('BOG STARTED') -------------just a debug   
     
end)

function CreateZone(data)
    OuterZone = lib.zones.poly({
        points = data.points,
        thickness = data.thickness,
        debug = true,
        debugColour = {r = 61, g = 220, b = 244},
        -- inside = insideouterzone,
    })
    Timer()
end

function Timer()
    TriggerServerEvent("SY_Bog:startCountdown", Config.Timer)
end

function startCaptureZone(data)
    Capturetime = data.capture_time
    CaptureZone = lib.zones.sphere({
        name = data.name,
        coords = data.capturezone,
        radius = 4.0,
        debug = true,
        inside = inside,
        onEnter = onEnter,
        onExit = onExit,
        debugColour = { r = 254, g = 150, b = 52 }
    })
    ESX.Game.SpawnLocalObject(Config.Object_flag.objModel, data.capturezone, function(obj)
        PlaceObjectOnGroundProperly(obj)
        FreezeEntityPosition(obj, true)
        SetEntityHeading(obj, 0)
        spawnedObj = obj
    end)
end

function inside(self)
    if IsControlJustPressed(0, 38) then
        if lib.progressBar({
                duration = Capturetime * 60000,
                label = locale('capturing', self.name),
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                },
                anim = {
                    dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
                    clip = 'machinic_loop_mechandplayer'
                },

            })
        then
            GiveReward()
        else
            lib.notify({
                id = 'error_ontification',
                title = 'SY_Bog',
                description = 'Failed to Capture the ' .. self.name,
                position = 'top',
                duration = 3500,
                style = {
                    backgroundColor = '#141517',
                    color = '#C1C2C5',
                    ['.description'] = {
                        color = '#909296'
                    }
                },
                icon = 'xmark',
                iconColor = '#C53030'
            })
        end
    end
end

function onEnter(self)
    lib.showTextUI('Press [E] to capture ' .. self.name, {
        position = "right-center",
        icon = 'fa-brands fa-keycdn',
        style = {
            borderRadius = 8,
            backgroundColor = 'rgb(240 24 121 / 50%)',
            color = 'white'
        }
    })
end

function onExit(self)
    lib.hideTextUI()
    if lib.progressActive() then
        lib.cancelProgress()
    end
end

function GiveReward()
    RemoveZones()
end

function RemoveZones()
    TriggerServerEvent("SY_Bog:server:hideCountdown")
    TriggerServerEvent('SY_Bog:server:removeOuterZone')
end

RegisterNetEvent('SY_Bog:client:removeOuterZone')
AddEventHandler('SY_Bog:client:removeOuterZone', function()
    if CaptureZone and OuterZone then
        CaptureZone:remove()
        OuterZone:remove()
    end
end)

function RespawnPed(ped, coords, heading)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
    -- SetPlayerInvincible(ped, false)
    -- ClearPedBloodDamage(ped)
end

function PlayerKilledByPlayer(killerServerId, killerClientId, deathCause)
    local weapon = ESX.GetWeaponFromHash(deathCause) ---ESX
    local data = {
        killedByPlayer = true,
        deathCause = deathCause,
        killerServerId = killerServerId,
        killerClientId = killerClientId,
        weapon = weapon?.name or "hand"
    }
    local victimCoords = GetEntityCoords(PlayerPedId()) -- Get the coordinates of the victim (local player)
    local isInsideOuterZone = OuterZone:contains(vec3(victimCoords.x, victimCoords.y, victimCoords.z))

    if isInsideOuterZone and Config.DisplayKillfeed then
        TriggerServerEvent('SY_Bog:onPlayerDead', data)
    end
    -- if Config.DisplayKillfeed then
    --     TriggerServerEvent('SY_Bog:onPlayerDead', data)
    -- end
end

RegisterNetEvent('SY_Bog:ShowKillfeed')
AddEventHandler('SY_Bog:ShowKillfeed', function(data)
    _victim = data.victim
    _killer = data.killerServerId
    _weapon = data.weapon
    SendNUIMessage({
        action = "killfeed",
        victim = _victim,
        killer = _killer,
        weapon = _weapon
    })
end)

-- ████████╗██╗███╗   ███╗███████╗██████╗
-- ╚══██╔══╝██║████╗ ████║██╔════╝██╔══██╗
--    ██║   ██║██╔████╔██║█████╗  ██████╔╝
--    ██║   ██║██║╚██╔╝██║██╔══╝  ██╔══██╗
--    ██║   ██║██║ ╚═╝ ██║███████╗██║  ██║
--    ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝


RegisterNetEvent("SY_Bog:showCountdown")
AddEventHandler("SY_Bog:showCountdown", function(time)
    SendNUIMessage({
        action = "show",
        time = time
    })
end)

RegisterNetEvent("SY_Bog:updateCountdown")
AddEventHandler("SY_Bog:updateCountdown", function(time)
    SendNUIMessage({
        action = "update",
        time = time
    })
end)

RegisterNetEvent("SY_Bog:hideCountdown")
AddEventHandler("SY_Bog:hideCountdown", function()
    SendNUIMessage({
        action = "hide"
    })
end)


RegisterNUICallback("hideCountdown", function()
    TriggerServerEvent("SY_Bog:server:hideCountdown")
end)
