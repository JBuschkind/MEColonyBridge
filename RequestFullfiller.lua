local basalt = require("basalt")
local colonies = peripheral.wrap("top")
local ae2 = peripheral.wrap("bottom")
local chatBox = peripheral.wrap("back")
local toolMaterial = "stone"
local armorMaterial = "chainmail"
--UI Variables
local main = basalt.createFrame():setScrollable():setTheme({FrameBG = colors.lightGray, FrameFG = colors.black})
local sub = {                                                              -- here we create a table where we gonna add some frames
    main:addFrame():setPosition(1, 2):setSize("parent.w", "parent.h - 1"), -- obviously the first one should be shown on program start
    main:addFrame():setPosition(1, 2):setSize("parent.w", "parent.h - 1"):hide():setScrollable(),
    main:addFrame():setPosition(1, 2):setSize("parent.w", "parent.h - 1"):hide():setScrollable()
}
local titleLabel = main:addLabel():setText("RequestFullfiller v0.1"):setSize(25):setPosition("parent.w / 2 + 2", 1):setBackground(colors.gray)
local craftableLabel = sub[2]:addLabel():setText("Craftable:"):setSize(10):setPosition(2, 4)
local uncraftableLabel = sub[2]:addLabel():setText("Uncraftable:"):setSize(10):setPosition("parent.w / 2 - 3",4)
local autoCraftLabel = sub[3]:addLabel():setText("Autoraft:"):setSize(10):setPosition(2,3)

checkAutoCraft = sub[3]:addCheckbox():setPosition(2,4):setSize(3)

uiListToCraft = sub[2]:addList():setPosition(2, 5):setScrollable():setSize("parent.w / 2 - 3", "parent.h -5")
uiListFailedToCraft = sub[2]:addList():setPosition("parent.w / 2  + 2", 5):setScrollable():setSize("parent.w / 2 - 3", "parent.h -5")
uiListAllToCraftItems = sub[1]:addList():setPosition(2, 5):setScrollable():setSize("parent.w / 2 - 3","parent.h -5")
local dropdownMaterialLabel = sub[3]:addLabel():setText("Tool Material:"):setSize(14):setPosition("parent.w / 2  + 2", 3)
local dropdownMaterial = sub[3]:addDropdown():setPosition("parent.w / 2  + 2", 4):addItem("stone"):addItem("iron"):addItem("diamond"):onChange(function(self, item)
    toolMaterial = item.text
  end)
local btnRefresh = sub[1]:addButton():setText("Refresh"):setPosition("parent.w / 2  + 2", 7):setSize(14)
local btnStartCraft = sub[1]:addButton():setText("Start Craft"):setPosition("parent.w / 2  + 2", 11):setSize(14)

craftThread = main:addThread():stop()

-- Program Variables
local availableCpus = ae2.getCraftingCPUs()
local listRequest = colonies.getRequests()
local craftedItems = {}
local rejectedItems = {}
craftList = {}


function openSubFrame(id)  -- we create a function which switches the frame for us
    if (sub[id] ~= nil) then
        for k, v in pairs(sub) do
            v:hide()
        end
        sub[id]:show()
    end
end

--Menu Bar
local menubar = main:addMenubar():setScrollable() -- we create a menubar in our main frame.
    :setSize("parent.w / 2")
    :onChange(function(self, val)
        openSubFrame(self:getItemIndex()) -- here we open the sub frame based on the table index
    end)
    :addItem("Start")
    :addItem("Crafting")
    :addItem("Settings")

function filterRequestList(list)
	local newList = {}
    local count = 0
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
            count = count +1
			print("Donum: " .. count)
            --basalt.debug("Domum: " .. count)
        else 
            basalt.debug("to craft: " .. v.name)
			replaceList.name = v.name
            replaceList.count = v.count
			table.insert(newList, replaceList)
        end
    end

    return newList
end

function parseColonyRequests()
    local count = 0
    local name = ""
    local parsedList = {}
    for krequest, vrequest in pairs(listRequest) do
        count = vrequest.count or 0  -- Falls nil, wird 0 verwendet
        for kitem, vitem in pairs(vrequest.items) do
			basalt.debug(vitem.name)
			basalt.debug(vrequest.count)
			local itemList = {}
			itemList.name = vitem.name
			itemList.count = vrequest.count		
			local itemData = ae2.getItem(itemList)
			--basalt.debug(itemData.count)
			if itemData and itemData.count then
				if (itemData.count > count) then	
					basalt.debug(ae2.getItem(itemList).name ..  ": ".. count .. "/" .. ae2.getItem(itemList).count .. " was stored and now pushed")  
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

function getIsCraftableCraftList(List)
    local craftingList = {}
    for k, v in pairs(List) do
        if v then 
			-- print(v)
			addToUIList(uiListToCraft, v)
			--if ae2.isItemCraftable(v) then
				-- print("craftable: ".. k .. " - " .. v.name)
				--table.insert(craftingList, v)
				--addToUIList(uiListToCraft, v)
				--basalt.debug("2. to craft: " .. v.name)
			--else
				--table.remove(List, k)
				-- print("uncraftablte:" .. k .. " - " .. v.name)
				--table.insert(rejectedItems, v)
				--addToUIList(uiListFailedToCraft,v)
				--chatBox.sendToastToPlayer(v.name .. " is currently uncraftable!", "Uncraftable", "J_Buschkind", "&eAutoCrafter", "><", "&c&l")
				-- basalt.debug("uncraft: " .. v.name)
				-- print(err)
			--end
        end
    end
    return craftingList
end

function printRejectedItems()
    for k, v in pairs(rejectedItems) do
        print(v.name)
    end
end

function printCraftList(list)
    basalt.debug("start")
    for k, v in pairs(list) do
        basalt.debug("item:" .. v.name)
        --       print(v.count)
    end
    basalt.debug("done")
end

-- Push trennen mit Anzahl Items, damit am Ende pruefbar
-- ob gecrafted wurde (Items vorher count 0)
function craftAndPushItems(list)
    for k, v in pairs(list) do
        ae2.craftItem(v)
        print("crafted:" .. tostring(v.name) .. " - " .. tostring(v.count or 0))
        sleep(1)
        ae2.exportItemToPeripheral(v, "right")
    end
end

function addToUIList(ui, list)
    local pos = string.find(list.name,":") + 1
    ui:addItem(string.sub(list.name, pos, string.len(list.name)).. " - " .. list.count)
end
function generateCraftList()
    craftList = nil
    craftList = {}
    craftList = parseColonyRequests()
    craftList = filterRequestList(craftList)
    craftList = getIsCraftableCraftList(craftList)
	basalt.debug("Sleep")
	os.sleep(15)
	generateCraftList()	
end

function refreshAll()
    listRequest = colonies.getRequests()
    uiListToCraft:clear()
    uiListAllToCraftItems:clear()
    uiListFailedToCraft:clear()
    --print("refresh done")
    generateCraftList()

end
function autoCraftThreadTask()
    while checkAutoCraft:getValue() do
        basalt.debug("AutoCrafter Started")
        chatBox.sendToastToPlayer("started Autocrafting Tasks", "AutoCraft", "J_Buschkind", "&eAutoCrafter", "><", "&c&l")
        refreshAll()
        generateCraftList()
        craftAndPushItems(craftList)
        basalt.debug("AutoCrafter End 15 sec Sleep")
        os.sleep(60)
    end
    
end    


-- UI functions


btnRefresh:onClick(function(self,event,button,x,y)
    refreshAll()
  end)
btnStartCraft:onClick(function (self,event,button,x,y)
    btnRefresh:disable()
    btnStartCraft:disable()
    craftAndPushItems(craftList)
    refreshAll()
    btnRefresh:enable()
    btnStartCraft:enable()
end)

checkAutoCraft:onChange(function (self)
    local checked = self:getValue()

    if checked then
        craftThread:start(autoCraftThreadTask())
        basalt.debug("Timer enabled")
    else
        craftThread:stop()
        basalt.debug("Timer disabled")
    end
end)

generateCraftList()
--printRejectedItems()
--print("--------------------------")
-- craftAndPushItems(craftList)

basalt.autoUpdate()
