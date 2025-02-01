
local colonies = peripheral.wrap("bottom")
local ae2 = peripheral.wrap("right")
local chatBox = peripheral.wrap("back")
local warehouse = peripheral.wrap("left")
local listRequest = colonies.getRequests()
local toolMaterial = "stone"
local armorMaterial = "leather"


function filterRequestList(list)
	local newList = {}
    for k, v in pairs(list) do
        local replaceList = {}
        if string.find(v.name, "_hoe") then
            table.remove(list, k)
            replaceList.name = "minecraft:" .. toolMaterial .. "_hoe"
            replaceList.count = 1
            table.insert(newList, replaceList)
        elseif string.find(v.name, "_axe") or string.find(v.name, "_paxel") then
            table.remove(list, k)
            replaceList.name = "minecraft:" .. toolMaterial .. "_axe"
            replaceList.count = 1
            table.insert(newList, replaceList)
        elseif string.find(v.name, "_pickaxe") then
            table.remove(list, k)
            replaceList.name = "minecraft:" .. toolMaterial .. "_pickaxe"
            replaceList.count = 1
            table.insert(newList, replaceList)
        elseif string.find(v.name, "_shovel") then
            table.remove(list, k)
            replaceList.name = "minecraft:" .. toolMaterial .. "_shovel"
            replaceList.count = 1
            table.insert(newList, replaceList)
        elseif string.find(v.name, "_sword") or string.find(v.name, "_machete") then
            table.remove(list, k)
            replaceList.name = "minecraft:" .. toolMaterial .. "_sword"
            replaceList.count = 1
            table.insert(newList, replaceList)
        elseif string.find(v.name, "_helmet") then
            table.remove(list, k)
            replaceList.name = "minecraft:" .. armorMaterial .. "_helmet"
            replaceList.count = 1
            table.insert(newList, replaceList)
        elseif string.find(v.name, "_chestplate") or string.find(v.name, "jetpack") then
            table.remove(list, k)
            replaceList.name = "minecraft:" .. armorMaterial .. "_chestplate"
            replaceList.count = 1
            table.insert(newList, replaceList)
        elseif string.find(v.name, "_leggings") then
            table.remove(list, k)
            replaceList.name = "minecraft:" .. armorMaterial .. "_leggings"
            replaceList.count = 1
            table.insert(newList, replaceList)
        elseif string.find(v.name, "_boots") or string.find(v.name, "_runners") then
            table.remove(list, k)
            replaceList.name = "minecraft:" .. armorMaterial .. "_boots"
            replaceList.count = 1
            table.insert(newList, replaceList) 
        elseif string.find(v.name, "domum_ornamentum:") then
            table.remove(list, k)
            --basalt.debug("Domum: " .. count)
        else 
            --basalt.debug("to craft: " .. v.name)
			replaceList.name = v.name
            replaceList.count = v.count
			table.insert(newList, replaceList)
        end
    end

    return newList
end

function parseColonyRequests()
    local parsedList = {}
    for krequest, vrequest in pairs(listRequest) do
        for kitem, vitem in pairs(vrequest.items) do
			--basalt.debug(vitem.name)
			--basalt.debug(vrequest.count)
			print(vitem.name .. " " .. vrequest.count)
			local itemList = {}
			itemList.name = vitem.name
			itemList.count = vrequest.count		
			local itemData = ae2.getItem(itemList)
			--basalt.debug(itemData.count)
			if itemData and itemData.count then
				if (itemData.count > vrequest.count	) then	
					--basalt.debug(ae2.getItem(itemList).name ..  ": ".. count .. "/" .. ae2.getItem(itemList).count .. " was stored and now pushed")  
					ae2.exportItemToPeripheral(itemList, "right")
				else
					table.insert(parsedList, itemList)
					addToUIList(uiListAllToCraftItems, itemList) 
				end
			end    
		end        
    end
    printCraftList(parsedList)
    return parsedList
end


while true do
	listRequest = colonies.getRequests()
	parseColonyRequests()	
	os.sleep(15)
end