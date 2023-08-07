local VorpCore
local VorpInv
TriggerEvent("getCore",function(core)
    VorpCore = core
end)

VorpInv = exports.vorp_inventory:vorp_inventoryApi()

local TEXTS = Config.Texts
local TEXTURES = Config.Textures

Citizen.CreateThread(function()
    Wait(500)
    for i,v in pairs(Config.ItemHash) do 
        local a = tostring(i)
        VorpInv.RegisterUsableItem(a, function(data)
            local _source = data.source
            local count = VorpInv.getItemCount(_source,i)
            if count and count > 0 then
                Citizen.Wait(200)
                count = VorpInv.getItemCount(_source, i)
                if count and count > 0 then
                    VorpInv.subItem(_source, a, 1)
                    TriggerClientEvent("ricx_pelt_trader:create_pelt", _source, v)
                end
                VorpInv.CloseInv(_source)
            end
        end)
    end
end)
local function GetLabel(item)
    local a = nil
    for i,v in pairs(Config.Pelts) do 
        if v[2] == item then 
            a = v[1]
        end
    end
    return a
end

RegisterServerEvent("ricx_pelt_trader:")
AddEventHandler("ricx_pelt_trader:", function()
    local _source = source
end)

RegisterServerEvent("ricx_pelt_trader:check_shop")
AddEventHandler("ricx_pelt_trader:check_shop", function(id)
    local _source = source
    local shop = Config.PeltTraders[id]
    local canopen = true 
    if shop.job ~= false then 
        canopen = false 
        local job = ""
        local Character = VorpCore.getUser(_source).getUsedCharacter
        job =  Character.job
        for i,v in pairs(shop.job) do 
            if job == v then 
                canopen = true 
                break
            end
        end
    end
    if canopen then
        local senditems = {}
        local inventory = VorpInv.getUserInventory(_source)
        for i,v in pairs(inventory) do
            if Config.ItemHash[v.name] then 
                local nr = #senditems + 1
                local p = Config.ItemHash[v.name].price * shop.multiplier
                senditems[nr] = {
                    item = v.name, 
                    label = v.label,
                    price = p, 
                    amount = v.count,
                }
            end
            Wait(50)
        end
        if #senditems > 0 then
            TriggerClientEvent("ricx_pelt_trader:open_shop", _source, id, senditems)
        else
            TriggerClientEvent("Notification:left_pelt_trader", _source, TEXTS.PeltTrader, TEXTS.NoItems, TEXTURES.alert[1], TEXTURES.alert[2], 2000)
        end
    else
        TriggerClientEvent("Notification:left_pelt_trader", _source, TEXTS.PeltTrader, TEXTS.NoJob, TEXTURES.alert[1], TEXTURES.alert[2], 2000)
    end
end)

RegisterServerEvent("ricx_pelt_trader:add_item")
AddEventHandler("ricx_pelt_trader:add_item", function(holding)
    local _source = source
    local peltInfo = nil 
    for c,k in pairs(Config.Pelts) do 
        if holding == c then 
            peltInfo = k
            break
        end
    end
    if peltInfo ~= nil then 
        VorpInv.addItem(_source, peltInfo[2], 1)
        TriggerClientEvent("Notification:left_pelt_trader", _source, TEXTS.Pelt, TEXTS.StoredPelt, TEXTURES.alert[1], TEXTURES.alert[2], 2000)
    end
end)

RegisterServerEvent("ricx_pelt_trader:sell_item_shop")
AddEventHandler("ricx_pelt_trader:sell_item_shop", function(id, datas)
    local _source = source 
    local shop = Config.PeltTraders[id]
    local price = datas.price 
    local item = datas.item 
    local label = datas.label 
    local count = VorpInv.getItemCount(_source, item)
    if count and count > 0 then 
        local sum = price * count 
        VorpInv.subItem(_source, item, count)
        local Character = VorpCore.getUser(_source).getUsedCharacter
        Character.addCurrency(0 , tonumber(sum))
        TriggerClientEvent("Notification:left_pelt_trader", _source, TEXTS.PeltTrader, TEXTS.Sold.." "..label..TEXTS.For.." $"..sum, TEXTURES.alert[1], TEXTURES.alert[2], 2000)
    else
        TriggerClientEvent("Notification:left_pelt_trader", _source, TEXTS.PeltTrader, TEXTS.NoItems, TEXTURES.alert[1], TEXTURES.alert[2], 2000)
    end
end)

RegisterServerEvent("ricx_pelt_trader:sell_item")
AddEventHandler("ricx_pelt_trader:sell_item", function(id, holding, entity)
    local _source = source
    local peltInfo = nil 
    local shop = Config.PeltTraders[id]
    local canopen = true 
    if shop.job ~= false then 
        canopen = false 
        local Character = VorpCore.getUser(_source).getUsedCharacter
        local job =  Character.job
        for i,v in pairs(shop.job) do 
            if job == v then 
                canopen = true 
                break
            end
        end
    end
    if canopen then
        for c,k in pairs(Config.ItemHash) do 
            if holding == k.hash then 
                peltInfo = k
                break
            end
        end
        if peltInfo ~= nil then 
            TriggerClientEvent("ricx_pelt_trader:remove_ent", _source, entity)
            local price = peltInfo.price
            local multiplier = shop.multiplier
            local sum = price * multiplier
            local Character = VorpCore.getUser(_source).getUsedCharacter
            Character.addCurrency(0 , tonumber(sum))
            TriggerClientEvent("Notification:left_pelt_trader", _source, TEXTS.PeltTrader, TEXTS.SoldPelt.." +$"..sum, TEXTURES.alert[1], TEXTURES.alert[2], 2000)
        end
    else
        TriggerClientEvent("Notification:left_pelt_trader", _source, TEXTS.PeltTrader, TEXTS.NoJob, TEXTURES.alert[1], TEXTURES.alert[2], 2000)
    end
end)