local config = require 'config.server'
local sharedConfig = require 'config.shared'

---@param id string
---@param reason string
local function exploitBan(id, reason)
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)',
        {
            GetPlayerName(id),
            GetPlayerIdentifierByType(id, 'license'),
            GetPlayerIdentifierByType(id, 'discord'),
            GetPlayerIdentifierByType(id, 'ip'),
            reason,
            2147483647,
            'qb-pawnshop'
        }
    )
    TriggerEvent('qb-log:server:CreateLog', 'pawnshop', 'Player Banned', 'red', string.format('%s was banned by %s for %s', GetPlayerName(id), 'qb-pawnshop', reason), true)
    DropPlayer(id, 'You were permanently banned by the server for: Exploiting')
end

---@param src number
---@return number
local function getClosestPawnShopDistance(src)
    local playerCoords = GetEntityCoords(GetPlayerPed(src))
    local dist

    for _, value in pairs(sharedConfig.pawnLocation) do
        dist = #(playerCoords - value.coords)
        if #(playerCoords - value.coords) < 2 then
            dist = #(playerCoords - value.coords)
            break
        end
    end

    return dist
end

RegisterNetEvent('qb-pawnshop:server:sellPawnItems', function(itemName, itemAmount, itemPrice)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    local totalPrice = (tonumber(itemAmount) * itemPrice)

    if getClosestPawnShopDistance(src) > 5 then exploitBan(src, 'sellPawnItems Exploiting') return end

    if Player.Functions.RemoveItem(itemName, tonumber(itemAmount)) then
        if config.bankMoney then
            Player.Functions.AddMoney('bank', totalPrice)
        else
            Player.Functions.AddMoney('cash', totalPrice)
        end
        exports.qbx_core:Notify(src, locale('success.sold', tonumber(itemAmount), exports.ox_inventory:Items()[itemName].label, totalPrice ), 'success')
        TriggerClientEvent('inventory:client:ItemBox', src, exports.ox_inventory:Items()[itemName], 'remove')
    else
        exports.qbx_core:Notify(src, locale('error.no_items'), 'error')
    end
    TriggerClientEvent('qb-pawnshop:client:openMenu', src)
end)

RegisterNetEvent('qb-pawnshop:server:meltItemRemove', function(itemName, itemAmount, item)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)
    if Player.Functions.RemoveItem(itemName, itemAmount) then
        TriggerClientEvent('inventory:client:ItemBox', src, exports.ox_inventory:Items()[itemName], 'remove')
        local meltTime = (tonumber(itemAmount) * item.time)
        TriggerClientEvent('qb-pawnshop:client:startMelting', src, item, itemAmount, (meltTime * 60000 / 1000))
        exports.qbx_core:Notify(src, locale('info.melt_wait', meltTime ), 'primary')
    else
        exports.qbx_core:Notify(src, locale('error.no_items'), 'error')
    end
end)

RegisterNetEvent('qb-pawnshop:server:pickupMelted', function(item)
    local src = source
    local Player = exports.qbx_core:GetPlayer(src)

    if getClosestPawnShopDistance(src) > 5 then exploitBan(src, 'pickupMelted Exploiting') return end

    for _, v in pairs(item.items) do
        local meltedAmount = v.amount
        for _, m in pairs(v.item.reward) do
            local rewardAmount = m.amount
            if Player.Functions.AddItem(m.item, (meltedAmount * rewardAmount)) then
                TriggerClientEvent('inventory:client:ItemBox', src, exports.ox_inventory:Items()[m.item], 'add')
                exports.qbx_core:Notify(src, locale('success.items_received', (meltedAmount * rewardAmount), exports.ox_inventory:Items()[m.item].label), 'success')
            else
                TriggerClientEvent('qb-pawnshop:client:openMenu', src)
                return
            end
        end
    end
    TriggerClientEvent('qb-pawnshop:client:resetPickup', src)
    TriggerClientEvent('qb-pawnshop:client:openMenu', src)
end)

lib.callback.register('qb-pawnshop:server:getInv', function(source)
    local Player = exports.qbx_core:GetPlayer(source)
    local inventory = Player.PlayerData.items
    return inventory
end)
