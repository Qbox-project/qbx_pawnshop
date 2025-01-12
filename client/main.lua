local config = require 'config.client'
local sharedConfig = require 'config.shared'
require "client.modules.compat"

local isMelting = false ---@type boolean
local canTake = false ---@type boolean
local meltTimeSeconds = 0 ---@type number
local meltedItem = {} ---@type {item: string, amount: number}[]

---@param id number
---@param shopConfig {coords: vector3, size: vector3, heading: number, debugPoly: boolean, distance: number}
local function addPawnShop(id, shopConfig)
    if config.useTarget then
        exports.ox_target:addBoxZone({
            coords = shopConfig.coords,
            size = shopConfig.size,
            rotation = shopConfig.heading,
            debug = shopConfig.debugPoly,
            options = {
                {
                    name = 'PawnShop' .. id,
                    event = 'qb-pawnshop:client:openMenu',
                    icon = 'fas fa-ring',
                    label = 'PawnShop ' .. id,
                    distance = shopConfig.distance
                }
            }
        })
    else
        lib.zones.box({
            name = 'PawnShop' .. id,
            coords = shopConfig.coords,
            size = shopConfig.size,
            rotation = shopConfig.heading,
            debug = shopConfig.debugPoly,
            onEnter = function()
                lib.registerContext({
                    id = 'open_pawnShopMain',
                    title = locale('info.title'),
                    options = {
                        {
                            title = locale('info.open_pawn'),
                            event = 'qb-pawnshop:client:openMenu'
                        }
                    }
                })
                lib.showContext('open_pawnShopMain')
            end,
            onExit = function()
                lib.hideContext(false)
            end
        })
    end
end

CreateThread(function()
    for id, shopConfig in pairs(sharedConfig.pawnLocation) do
        local blip = AddBlipForCoord(shopConfig.coords.x, shopConfig.coords.y, shopConfig.coords.z)
        SetBlipSprite(blip, 431)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipAsShortRange(blip, true)
        SetBlipColour(blip, 5)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(locale('info.title'))
        EndTextCommandSetBlipName(blip)

        addPawnShop(id, shopConfig)
    end
end)

RegisterNetEvent('qb-pawnshop:client:openMenu', function()
    if not config.useTimes then
        local pawnShop = {
            {
                title = locale('info.sell'),
                description = locale('info.sell_pawn'),
                event = 'qb-pawnshop:client:openPawn',
                args = {
                    items = config.pawnItems
                }
            }
        }
        if not isMelting then
            pawnShop[#pawnShop + 1] = {
                title = locale('info.melt'),
                description = locale('info.melt_pawn'),
                event = 'qb-pawnshop:client:openMelt',
                args = {
                    items = config.meltingItems
                }
            }
        end
        if canTake then
            pawnShop[#pawnShop + 1] = {
                title = locale('info.melt_pickup'),
                serverEvent = 'qb-pawnshop:server:pickupMelted',
                args = {
                    items = meltedItem
                }
            }
        end
        lib.registerContext({
            id = 'open_pawnShop',
            title = locale('info.title'),
            options = pawnShop
        })
        lib.showContext('open_pawnShop')
        return
    end

    local gameHour = GetClockHours()
    if gameHour < config.timeOpen or gameHour > config.timeClosed then
        exports.qbx_core:Notify(locale('info.pawn_closed', config.timeOpen, config.timeClosed))
        return
    end

    local pawnShop = {
        {
            title = locale('info.sell'),
            description = locale('info.sell_pawn'),
            event = 'qb-pawnshop:client:openPawn',
            args = {
                items = config.pawnItems
            }
        }
    }
    if not isMelting then
        pawnShop[#pawnShop + 1] = {
            title = locale('info.melt'),
            description = locale('info.melt_pawn'),
            event = 'qb-pawnshop:client:openMelt',
            args = {
                items = config.meltingItems
            }
        }
    end
    if canTake then
        pawnShop[#pawnShop + 1] = {
            title = locale('info.melt_pickup'),
            serverEvent = 'qb-pawnshop:server:pickupMelted',
            args = {
                items = meltedItem
            }
        }
    end
    lib.registerContext({
        id = 'open_pawnShop',
        title = locale('info.title'),
        options = pawnShop
    })
    lib.showContext('open_pawnShop')
end)

RegisterNetEvent('qb-pawnshop:client:startMelting', function(item, meltingAmount, _meltTimeSeconds)
    if isMelting then
        return
    end

    isMelting = true
    meltTimeSeconds = _meltTimeSeconds
    meltedItem = {}
    CreateThread(function()
        while isMelting and LocalPlayer.state.isLoggedIn and meltTimeSeconds > 0 do
            meltTimeSeconds = meltTimeSeconds - 1
            Wait(1000)
        end

        canTake = true
        isMelting = false
        table.insert(meltedItem, { item = item, amount = meltingAmount })

        if not config.sendMeltingEmail then
            exports.qbx_core:Notify(locale('info.message'), 'success')
            return
        end

        TriggerServerEvent('qb-phone:server:sendNewMail', {
            sender = locale('info.title'),
            subject = locale('info.subject'),
            message = locale('info.message'),
            button = {}
        })
    end)
end)

RegisterNetEvent('qb-pawnshop:client:resetPickup', function()
    canTake = false
end)