RegisterNetEvent('qb-pawnshop:client:openMelt', function(data)
	lib.callback('qb-pawnshop:server:getInv', false, function(inventory)
		local PlyInv = inventory
		local meltMenu = {}

		for _, v in pairs(PlyInv) do
			for i = 1, #data.items do
				if v.name == data.items[i].item then
					meltMenu[#meltMenu + 1] = {
						title = exports.ox_inventory:Items()[v.name].label,
						description = locale('info.melt_item', exports.ox_inventory:Items()[v.name].label),
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
			placeholder = locale('info.max', item.amount)
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
			placeholder = locale('info.max', item.amount)
		}
	})
	if meltingItem then
		if not meltingItem[1] or meltingItem[1] <= 0 then return end
		TriggerServerEvent('qb-pawnshop:server:meltItemRemove', item.name, meltingItem[1], item)
	else
		exports.qbx_core:Notify(locale('error.no_melt'), 'error')
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
						description = locale('info.sell_items', data.items[i].price),
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