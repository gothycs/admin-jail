local jailCoords = Config.JailCoords 
local releaseCoords = Config.ReleaseCoords
local jailPosition = nil
local playerPed = PlayerPedId()
local isInJail = false
local jailTimeRemaining = 0

RegisterNetEvent("adminJail:jailPlayer")
AddEventHandler("adminJail:jailPlayer", function(jailTime, position)
    jailPosition = position
    isInJail = true
    jailTimeRemaining = jailTime

    SetEntityCoords(playerPed, jailPosition.x, jailPosition.y, jailPosition.z, false, false, false, false)
    TriggerEvent("chat:addMessage", { args = { "^1[ADMIN]", " You have been sent to jail for " .. jailTimeRemaining / 60 .. " minutes." } })
end)

RegisterNetEvent("adminJail:releasePlayer")
AddEventHandler("adminJail:releasePlayer", function()
    isInJail = false
    jailPosition = nil
    SetEntityCoords(playerPed, releaseCoords.x, releaseCoords.y, releaseCoords.z, false, false, false, false)
    TriggerEvent("chat:addMessage", { args = { "^1[ADMIN]", " You have been released from jail." } })
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        if isInJail then
            local currentPos = GetEntityCoords(playerPed)
            local distance = #(currentPos - jailPosition)

            if distance > 10.0 then
                SetEntityCoords(playerPed, jailPosition.x + math.random(-5, 5), jailPosition.y + math.random(-5, 5), jailPosition.z)
            end

            if jailTimeRemaining > 0 then
                jailTimeRemaining = jailTimeRemaining - 1
            end
            if jailTimeRemaining <= 0 then
                TriggerServerEvent("unjail", GetPlayerServerId(PlayerId()))
            end
        end
    end
end)
