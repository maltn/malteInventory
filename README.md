# malteInventory
## **This resource is not meant for use, this is purely for show**
## **I have yet to finish this project which is why there is alot of functionalities missing

### UI Layout:


![Layout](https://i.imgur.com/6Xw3JFh.png)


### Dropping Items:


![Drop](https://i.imgur.com/v2Thoo6.jpg)


*Dropping items are stored in local memory as tables which with alot of items dropped could cause lag, might be smart to add a limit or delete items when they have been untouched for too long*


Using items:

```lua
-- If item is usable and ped *uses* it, the server side will trigger an event called itemUsed aswell as passing the item used
RegisterNetEvent("itemUsed")
AddEventHandler("itemUsed", function(item)
	if item == "apple" then
		--(other conditions such as isPedInVehicle or IsPedDeadOrDying
		--(trigger animation event to play eating animation)
		--add food to statusbar & database

		-- Removing item		
		TriggerServerEvent("malteInventory:updateItem", "armor")
	end
end)
```

Known Problems
> (I just haven't gotten around to fixing them, they're not hard to fix either)
> Items get splitted when picking up, this happens because I insert into the database instead of checking if it exists and then updating
> Having multiple of same type of item will cause it to use the first one in the database this can cause the amount of items to go below 0, same fix for this as the above and to be extra sure I just need to add a MAX(amount) so that it uses the item with the most amount
> Weight counter doesn't really do anything this isnt really a problem I just haven't added a check to make sure that theres is a consequence to having too much weight
 
