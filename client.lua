local itemstats = nil
local currentweight = nil
local droppedItems = {}
local objects = {}

function pickupAnimation()
	Citizen.CreateThread(function()
		RequestAnimDict("pickup_object")
		while (not HasAnimDictLoaded("pickup_object")) do Citizen.Wait(0) end
		TaskPlayAnim(GetPlayerPed(-1),"pickup_object","pickup_low",1.0,-1.0, 1000, 0, 1, true, true, true)
	end)
end

Citizen.CreateThread(function()
	while true do
		Wait(0)

		for i = 1, #droppedItems do
			local pos = GetEntityCoords(GetPlayerPed(-1))
			local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, droppedItems[i]["x"], droppedItems[i]["y"], droppedItems[i]["z"], true)
			
			if distance < 1.3 then
				if IsControlJustPressed(0, 23) then
					pickupAnimation()
				end
				if IsControlJustReleased(0, 23) then
					print("Pickup 1")
					DeleteObject(objects[i])
					table.remove(objects, i)
					TriggerServerEvent("malteInventory:pickup", droppedItems[i]["item"], droppedItems[i]["amount"])
					table.remove(droppedItems, i)
					break
				end
				local onScreen, _x, _y = World3dToScreen2d(droppedItems[i]["x"], droppedItems[i]["y"], droppedItems[i]["z"])

				SetTextScale(0.3, 0.3)
				SetTextFont(0)
				SetTextProportional(1)
				SetTextEntry("STRING")
				SetTextCentre(true)
				SetTextColour(255, 255, 255, 215)
				AddTextComponentString(droppedItems[i]["amount"] .. " " .. droppedItems[i]["item"] .. " [F]")
				
				DrawText(_x, _y + 0.002)
			
				local factor = (string.len(droppedItems[i]["item"])) / 200
				DrawRect(_x, _y + 0.0150, 0.03 + factor, 0.02, 0, 0, 0, 100)
			end
		end
	end
end)

AddEventHandler("onClientResourceStart", function(resource)
	if resource == "malteInventory" then
		TriggerServerEvent("malteInventory:pullItemInformation")
	end
end)

RegisterNetEvent("malteInventory:storeItemStats")
AddEventHandler("malteInventory:storeItemStats", function(result)
	itemstats = result
end)

RegisterNetEvent("malteInventory:open")
AddEventHandler("malteInventory:open", function(args)
	SetCursorLocation(0.3, 0.5)
	SetNuiFocus(true, true)
	SendNUIMessage({
		args = args,
		itemstats = itemstats,
		showhud = true
	})
	TransitionToBlurred(50000)
end)

Citizen.CreateThread(function()
	TransitionFromBlurred(1)
	while true do
		Wait(0)
		if IsControlJustReleased(0, 289) then
			TriggerServerEvent("malteInventory:openingInventoryPullItems")
		end
	end
end)

RegisterNUICallback("close", function(data, cb)
	TransitionFromBlurred(1)
	SetNuiFocus(false, false)
	SendNUIMessage({
		showhud = false
	})
end)

AddEventHandler("onResourceStop", function(resource)
	if resource == "malteInventory" then
		for i = 1, #objects do
			DeleteObject(objects[i])
		end
	end
end)


function dropProp()
	local model = "prop_paper_bag_01"
	Citizen.CreateThread(function()
		RequestModel(model)

		local iterations = 0
		while not HasModelLoaded(model) do
    		Citizen.Wait(100)
			iterations = iterations + 1
			if iterations > 5000 then
				break
			end
        end

		if not HasModelLoaded(model) then
    		SetModelAsNoLongerNeeded(model)
    	else
			local pCoords = GetEntityCoords(GetPlayerPed(-1))
            local created_object = CreateObjectNoOffset(model, pCoords.x, pCoords.y, pCoords.z, 1, 0, 1)
            PlaceObjectOnGroundProperly(created_object)
            FreezeEntityPosition(created_object,true)
			table.insert(objects, created_object)
            SetModelAsNoLongerNeeded(model)
         end

	end)
end

RegisterNUICallback("drop", function(data, cb)
	dropProp()
	local pos = GetEntityCoords(GetPlayerPed(-1))
	table.insert(droppedItems, {["item"] = data.item,["amount"] = data.amount, ["x"] = pos.x, ["y"] = pos.y, ["z"] = pos.z - 0.7})
	--table.insert(droppedItems, {data.item, pos.x, pos.y, pos.z - 0.7})
	print(json.encode(droppedItems))
	TriggerServerEvent("malteInventory:dropItem", data.item, data.amount)
end)

RegisterNUICallback("use", function(data, cb)
	TriggerEvent("itemUsed", data.item)
end)


