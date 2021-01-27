local origInit = init or function() end
local origGenerateShipLists = generateShipLists or function() end
local origChangeState = changeState or function(newState) end

function init()
	origInit()
	
	-- to disable this until the rest of the system is ready (completely remove it when it is ready)
	if true then
		return
	end
	
	if player.species() == "Ketian" then
		states.initial = states.ketianInitial or states.initial
		changeState(state.state)
	end
end

function generateShipLists()
	origGenerateShipLists()
	
	ship.ketianShipConfig = ship.ketianShipConfig or root.assetJson("/frackinship/configs/ketianships.config")
	ship.ketianShips = {}
	local playerRace = player.species()
	for id, data in pairs (ship.ketianShipConfig) do
		local addShip = true
		if data.universeFlag then
			addShip = false
			if not ship.disableUnlockableShips then
				for _, flag in ipairs (ship.universeFlags or {}) do
					if flag == data.universeFlag then
						addShip = true
						break
					end
				end
			end
		end
		local ignoreShip = false
		if data.raceWhitelist and not data.raceWhitelist[playerRace] then
			ignoreShip = true
		elseif data.raceBlacklist and data.raceBlacklist[playerRace]  and not data.raceWhitelist then
			ignoreShip = true
		end
		if addShip and not ignoreShip then
			data.id = id
			data.mode = "Buildable"
			table.insert(ship.ketianShips, data)
		end
	end
	
	table.sort(ship.ketianShips, compareByName)
end

function changeState(newState)
	origChangeState(newState)
	if states[newState] then
		if newState == "ketianShipChoice" then
			widget.setVisible("root.shipList", true)
			for i = 1, 3 do
				widget.setButtonEnabled("button" .. i, false)
			end
			populateShipList(ship.ketianShips)
		elseif newState == "ketianShipPreview" then
			widget.setVisible("root", false)
			if ship.selectedShip then
				widget.setVisible("preview", true)
				widget.setImage("preview", ship.selectedShip.previewImage or "")
			end
		elseif newState == "ketianShipSelected" then
			local text = state.text
			if text and ship.selectedShip then
				text = text:gsub("<shipName>", tostring(ship.selectedShip.name))
				typeText(text)
			end
		elseif newState == "ketianShipChosen" then
			createShip()
			changeState("shipChosen")
		end
	end
end