local config = require 'config.client'
local sharedConfig = require 'config.shared'
local isMelting = false ---@type boolean
local canTake = false ---@type boolean
local meltTimeSeconds = 0 ---@type number
local meltedItem = {} ---@type {item: string, amount: number}[]

CreateThread(function()
    for _, value in pairs(sharedConfig.pawnLocation) do
        local blip = AddBlipForCoord(value.coords.x, value.coords.y, value.coords.z)
        SetBlipSprite(blip, 431)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipAsShortRange(blip, true)
        SetBlipColour(blip, 5)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(locale('info.title'))
        EndTextCommandSetBlipName(blip)
    end
end)

CreateThread(function()
    if config.useTarget then
        for key, value in pairs(sharedConfig.pawnLocation) do
            exports.ox_target:addBoxZone({
                coords = value.coords,
                size = value.size,
                rotation = value.heading,
                debug = value.debugPoly,
                options = {
                    {
                        name = 'PawnShop' .. key,
                        event = 'qb-pawnshop:client:openMenu',
                        icon = 'fas fa-ring',
                        label = 'PawnShop ' .. key,
                        distance = value.distance
                    }
                }
            })
        end
    else
        local zone = {}
        for key, value in pairs(sharedConfig.pawnLocation) do
            zone[#zone + 1] = lib.zones.box({
                name = 'PawnShop' .. key,
                coords = value.coords,
                size = value.size,
                rotation = value.heading,
                debug = value.debugPoly,
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
end)

RegisterNetEvent('qb-pawnshop:client:openMenu', function()
    if config.useTimes then
        if GetClockHours() >= config.timeOpen and GetClockHours() <= config.timeClosed then
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
        else
            exports.qbx_core:Notify(locale('info.pawn_closed', config.timeOpen,  config.timeClosed ))
        end
    else
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
    end
end)

RegisterNetEvent('qb-pawnshop:client:openPawn', function(data)
    lib.callback('qb-pawnshop:server:getInv', false, function(inventory)
        local PlyInv = inventory
        local pawnMenu = {}

        for _, v in pairs(PlyInv) do
            for i = 1, #data.items do
                if v.name == data.items[i].item then
                    pawnMenu[#pawnMenu + 1] = {
                        title = exports.ox_inventory:Items()[v.name].label,
                        description = locale('info.sell_items', data.items[i].price ),
                        event = 'qb-pawnshop:client:pawnitems',
                        args = {
                            label = exports.ox_inventory:Items()[v.name].label,
                            price = data.items[i].price,
                            name = v.name,
                            amount = v.amount
                        }
                    }
                end
            end
        end
        lib.registerContext({
            id = 'open_pawnMenu',
            menu = 'open_pawnShop',
            title = locale('info.title'),
            options = pawnMenu
        })
        lib.showContext('open_pawnMenu')
    end)
end)

RegisterNetEvent('qb-pawnshop:client:openMelt', function(data)
    lib.callback('qb-pawnshop:server:getInv', false, function(inventory)
        local PlyInv = inventory
        local meltMenu = {}

        for _, v in pairs(PlyInv) do
            for i = 1, #data.items do
                if v.name == data.items[i].item then
                    meltMenu[#meltMenu + 1] = {
                        title = exports.ox_inventory:Items()[v.name].label,
                        description = locale('info.melt_item', exports.ox_inventory:Items()[v.name].label ),
                        event = 'qb-pawnshop:client:meltItems',
                        args = {
                            label = exports.ox_inventory:Items()[v.name].label,
                            reward = data.items[i].rewards,
                            name = v.name,
                            amount = v.amount,
                            time = data.items[i].meltTime
                        }
                    }
                end
            end
        end
        lib.registerContext({
            id = 'open_meltMenu',
            menu = 'open_pawnShop',
            title = locale('info.title'),
            options = meltMenu
        })
        lib.showContext('open_meltMenu')
    end)
end)

RegisterNetEvent('qb-pawnshop:client:pawnitems', function(item)
    local sellingItem = lib.inputDialog(locale('info.title'), {
        {
            type = 'number',
            label = 'amount',
            placeholder = locale('info.max', item.amount )
        }
    })
    if sellingItem then
        if not sellingItem[1] or sellingItem[1] <= 0 then return end
        TriggerServerEvent('qb-pawnshop:server:sellPawnItems', item.name, sellingItem[1], item.price)
    else
        exports.qbx_core:Notify(locale('error.negative'), 'error')
    end
end)

RegisterNetEvent('qb-pawnshop:client:meltItems', function(item)
    local meltingItem = lib.inputDialog(locale('info.melt'), {
        {
            type = 'number',
            label = 'amount',
            placeholder = locale('info.max', item.amount )
        }
    })
    if meltingItem then
        if not meltingItem[1] or meltingItem[1] <= 0 then return end
        TriggerServerEvent('qb-pawnshop:server:meltItemRemove', item.name, meltingItem[1], item)
    else
        exports.qbx_core:Notify(locale('error.no_melt'), 'error')
    end
end)

RegisterNetEvent('qb-pawnshop:client:startMelting', function(item, meltingAmount, _meltTimeSeconds)
    if not isMelting then
        isMelting = true
        meltTimeSeconds = _meltTimeSeconds
        meltedItem = {}
        CreateThread(function()
            while isMelting do
                if LocalPlayer.state.isLoggedIn then
                    meltTimeSeconds = meltTimeSeconds - 1
                    if meltTimeSeconds <= 0 then
                        canTake = true
                        isMelting = false
                        table.insert(meltedItem, { item = item, amount = meltingAmount })
                        if config.sendMeltingEmail then
                            TriggerServerEvent('qb-phone:server:sendNewMail', {
                                sender = locale('info.title'),
                                subject = locale('info.subject'),
                                message = locale('info.message'),
                                button = {}
                            })
                        else
                            exports.qbx_core:Notify(locale('info.message'), 'success')
                        end
                    end
                else
                    break
                end
                Wait(1000)
            end
        end)
    end
end)

RegisterNetEvent('qb-pawnshop:client:resetPickup', function()
    canTake = false
end)
