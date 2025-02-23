local InService    = {}
local MaxInService = {}

function GetInServiceCount(name)
	local count = 0

	for k,v in pairs(InService[name]) do
		if v == true then
			count = count + 1
		end
	end

	return count
end

RegisterServerEvent('esx_service:activateService')
AddEventHandler('esx_service:activateService', function(name, max)
	InService[name] = {}
	MaxInService[name] = max
	GlobalState[name] = GetInServiceCount(name)
end)

RegisterServerEvent('esx_service:disableService')
AddEventHandler('esx_service:disableService', function(name)
	local source = source
	InService[name][source] = nil
	GlobalState[name] = GetInServiceCount(name)
	Player(source).state:set('onduty', false, true)
	TriggerClientEvent('esx:showNotification', source, "Vous n'êtes plus en service") -- Need to add translation system
end)

RegisterServerEvent('esx_service:notifyAllInService')
AddEventHandler('esx_service:notifyAllInService', function(notification, name)
	for k,v in pairs(InService[name]) do
		if v == true then
			TriggerClientEvent('esx_service:notifyAllInService', k, notification, source)
		end
	end
end)

ESX.RegisterServerCallback('esx_service:enableService', function(source, cb, name)
	local inServiceCount = GetInServiceCount(name)
	local source = source
	if inServiceCount >= MaxInService[name] then
		cb(false, MaxInService[name], inServiceCount)
	else
		InService[name][source] = true
		GlobalState[name] = GetInServiceCount(name)
		Player(source).state:set('onduty', true, true)
		TriggerClientEvent('esx:showNotification', source, "Vous avez pris votre service") -- Need to add translation system
		cb(true, MaxInService[name], inServiceCount)		
	end
end)

ESX.RegisterServerCallback('esx_service:isInService', function(source, cb, name)
	local isInService = false

	if InService[name] ~= nil then
		if InService[name][source] then
			isInService = true
		end
	else
		print(('[^3WARNING^7] Attempted To Use Inactive Service - ^5%s^7'):format(name))
	end

	cb(isInService)
end)

ESX.RegisterServerCallback('esx_service:isPlayerInService', function(source, cb, name, target)
	local isPlayerInService = false
	local targetXPlayer = ESX.GetPlayerFromId(target)

	if InService[name][targetXPlayer.source] then
		isPlayerInService = true
	end

	cb(isPlayerInService)
end)

ESX.RegisterServerCallback('esx_service:getInServiceList', function(source, cb, name)
	cb(InService[name])
end)

AddEventHandler('esx:playerDropped', function(playerId, reason)
	for k,v in pairs(InService) do
		if v[playerId] == true then
			v[playerId] = nil
			GlobalState[k] = GetInServiceCount(k)
		end
	end
end)
