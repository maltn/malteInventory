RegisterServerEvent("malteInventory:dropItem")
AddEventHandler("malteInventory:dropItem", function(thing, mangd)
    local mangd = tonumber(mangd)
    local src = source
    local aChar = Malte.char(source)
    if Malte.validItem(thing) then
        MySQL.Async.fetchScalar('SELECT MAX(amount) FROM inventory WHERE item = @item AND charid = @char', {['@item'] = thing, ['@char'] = aChar}, function(result)
            local amount = result
            if amount == mangd then
                MySQL.Async.execute('DELETE FROM inventory WHERE amount = @mangd AND charid = @char AND item = @item LIMIT 1',
                {['@mangd'] = amount, ['@char'] = aChar, ['@item'] = thing},
                function(affectedRows)
                end)
            else
                MySQL.Async.execute("UPDATE inventory SET amount = amount - @mangd WHERE charid = @char and item = @item LIMIT 1", {['@mangd'] = mangd, ['@char'] = aChar, ['@item'] = thing})
            end
        end)
    end
end)

RegisterServerEvent("malteInventory:pullItemInformation")
AddEventHandler("malteInventory:pullItemInformation", function()
    local src = source
    MySQL.ready(function()
        MySQL.Async.fetchAll("SELECT * FROM items", {}, function(result)
            TriggerClientEvent("malteInventory:storeItemStats", src, result)
        end)
    end)
end)

RegisterServerEvent("malteInventory:openingInventoryPullItems")
AddEventHandler("malteInventory:openingInventoryPullItems", function()
    local src = source
    local aChar = Malte.char(source)
    MySQL.ready(function()
        MySQL.Async.fetchAll("SELECT * FROM inventory WHERE charid = @char", { ['@char'] = aChar},
        function(result)
            local items = result
            TriggerClientEvent("malteInventory:open", src, items)
        end)
    end)
end)

--not here bug
RegisterServerEvent("malteInventory:addItem")
AddEventHandler("malteInventory:addItem", function(args, src)
    src = src or source
    local target = tonumber(args[1])
    local item = args[2]
    local amount = tonumber(args[3])
    if target == -1 then
        target = Malte.char(src)
    end

    local charname = Malte.name(target) 
    if amount ~= nil and amount > 0 then
        if Malte.validItem(item) then
            MySQL.ready(function()
                MySQL.Async.execute('INSERT INTO inventory (charname, charid, item, amount) VALUES (@name, @char, @item, @amount)', {['@name'] = charname, ['@char'] = target, ['@item'] = item, ['@amount'] = amount})
            end)
        end
    end
end)

RegisterServerEvent("malteInventory:pickup")
AddEventHandler("malteInventory:pickup", function(item, amount)
    local src = source
    local aChar = Malte.char(src)
    local charname = Malte.name(aChar)
    
    print("uwuwuwuuw")
    MySQL.ready(function()
        MySQL.Async.execute('INSERT INTO inventory (charname, charid, item, amount) VALUES (@charname, @char, @item, @amount)', { ['@charname'] = charname, ['@char'] = aChar, ['@item'] = item, ['@amount'] = amount },
        function(affectedRows)
            print("desu " .. affectedRows)
        end)
    end)
end)

RegisterCommand("addItem", function(source, args)
    TriggerEvent("malteInventory:addItem", args, source)
end, false)

RegisterServerEvent("malteInventory:updateItem")
AddEventHandler("malteInventory:updateItem", function(thing)
    local src = source
    local aChar = Malte.char(source)
    if Malte.validItem(thing) then
        MySQL.Async.fetchScalar('SELECT MAX(amount) FROM inventory WHERE item = @item AND charid = @char', {['@item'] = thing, ['@char'] = aChar}, function(result)
            local amount = result
            if amount == 1 then
                MySQL.Async.execute('DELETE FROM inventory WHERE charid = @char AND item = @item LIMIT 1',
                {['@char'] = aChar, ['@item'] = thing},
                function(affectedRows)
                end)
            else
                print("updated -1")
                MySQL.Async.execute("UPDATE inventory SET amount = amount - 1 WHERE charid = @char and item = @item LIMIT 1", {['@char'] = aChar, ['@item'] = thing})
            end
        end)
    end
end)