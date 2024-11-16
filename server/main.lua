ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('SY_Bog:server:startOuterZone')
AddEventHandler('SY_Bog:server:startOuterZone', function(data)
    TriggerClientEvent('SY_Bog:client:startOuterZone', -1, data)
end)
RegisterNetEvent('SY_Bog:server:removeOuterZone')
AddEventHandler('SY_Bog:server:removeOuterZone', function()
    TriggerClientEvent('SY_Bog:client:removeOuterZone', -1)
end)



-- ████████╗██╗███╗   ███╗███████╗██████╗
-- ╚══██╔══╝██║████╗ ████║██╔════╝██╔══██╗
--    ██║   ██║██╔████╔██║█████╗  ██████╔╝
--    ██║   ██║██║╚██╔╝██║██╔══╝  ██╔══██╗
--    ██║   ██║██║ ╚═╝ ██║███████╗██║  ██║
--    ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝

local countdownActive = false
local countdownTime = 0

RegisterNetEvent("SY_Bog:startCountdown")
AddEventHandler("SY_Bog:startCountdown", function(time)
    countdownActive = true
    countdownTime = time
    TriggerClientEvent("SY_Bog:showCountdown", -1, countdownTime)
    CreateThread(function()
        while countdownActive and countdownTime > 0 do
            Wait(1000)
            countdownTime = countdownTime - 1
            TriggerClientEvent("SY_Bog:updateCountdown", -1, countdownTime)
        end
        countdownActive = false
        countdownTime = 0
        -- TriggerClientEvent("SY_Bog:hideCountdown", -1)
    end)
end)

RegisterServerEvent('SY_Bog:server:hideCountdown')
AddEventHandler('SY_Bog:server:hideCountdown', function()
    countdownActive = false
    countdownTime = 0
    TriggerClientEvent("SY_Bog:hideCountdown", -1)
    if Config.Announcement then
        TriggerClientEvent('sy_announce:display', -1, 'ANNOUNCEMENT', "Bog Started", 10000)
    end
end)




RegisterServerEvent('SY_Bog:onPlayerDead')
AddEventHandler('SY_Bog:onPlayerDead', function(data)
    local victim = ESX.GetPlayerFromId(source)                        --ESX
    local killer = ESX.GetPlayerFromId(data.killerServerId) or victim --ESX
    data.victim = victim.getName()
    data.killerServerId = killer.getName()

    if data.killedByPlayer then
        TriggerClientEvent('SY_Bog:ShowKillfeed', -1, data)
    end
end)


lib.callback.register('SY_Bog:server:getjobs', function()
    local jobs = {}
    local isaJob = false
    jobs.input_table = {}
    for _, v in pairs(Config.GangJobs) do
        if v then
            table.insert(jobs.input_table, { value = v })
            isaJob = ESX.DoesJobExist(v, 0) or isaJob --ESX
        end
    end
    jobs.isaJob = isaJob
    return (jobs)
end)
