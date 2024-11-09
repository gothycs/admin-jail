local jailData = {}

function loadJailData()
    local data = LoadResourceFile(GetCurrentResourceName(), Config.JailFile)
    if data then
        jailData = json.decode(data) or {}
    end
end

function saveJailData()
    SaveResourceFile(GetCurrentResourceName(), Config.JailFile, json.encode(jailData), -1)
end

loadJailData()

RegisterCommand("jail", function(source, args)
    local playerIdentifier = GetPlayerIdentifiers(source)[1]
    if not Config.AdminList[playerIdentifier] then
        TriggerClientEvent('chat:addMessage', source, { args = { "^1[ADMIN]", " You do not have permission to use this command!" } })
        return
    end

    if not args[1] or not args[2] then
        TriggerClientEvent('chat:addMessage', source, { args = { "^1[ADMIN]", " Usage: /jail [Player ID] [minutes]" } })
        return
    end

    local targetId = tonumber(args[1])
    local jailTime = tonumber(args[2]) * 60 

    if targetId and jailTime then
        jailData[targetId] = {
            license = GetPlayerIdentifier(targetId, 0), 
            jailTime = jailTime, 
            jailPosition = Config.JailCoords
        }

        saveJailData()

        TriggerClientEvent("adminJail:jailPlayer", targetId, jailTime, Config.JailCoords)
        TriggerClientEvent('chat:addMessage', -1, { args = { "^1[ADMIN]", " Player " .. GetPlayerName(targetId) .. " has been sent to jail for " .. args[2] .. " minutes." } })
    end
end)

RegisterCommand("unjail", function(source, args)
    local targetId = tonumber(args[1])

    if targetId and jailData[targetId] then
        jailData[targetId] = nil

        saveJailData()

        TriggerClientEvent("adminJail:releasePlayer", targetId)
        TriggerClientEvent('chat:addMessage', -1, { args = { "^1[ADMIN]", " Player " .. GetPlayerName(targetId) .. " has been released from jail." } })
    else
        TriggerClientEvent('chat:addMessage', source, { args = { "^1[ADMIN]", " Usage: /unjail [Player ID]" } })
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        for playerId, data in pairs(jailData) do
            if data.jailTime > 0 then
                jailData[playerId].jailTime = data.jailTime - 1
                saveJailData()

                if data.jailTime <= 0 then
                    TriggerClientEvent("adminJail:releasePlayer", playerId)
                    TriggerClientEvent('chat:addMessage', -1, { args = { "^1[ADMIN]", " Player " .. GetPlayerName(playerId) .. " has been released from jail." } })
                    jailData[playerId] = nil
                    saveJailData()
                end
            end
        end
    end
end)
