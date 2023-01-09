-- Auto Updater from https://github.com/hexarobi/stand-lua-auto-updater
local status, auto_updater = pcall(require, "auto-updater")
if not status then
    local auto_update_complete = nil util.toast("Installing auto-updater...", TOAST_ALL)
    async_http.init("raw.githubusercontent.com", "/hexarobi/stand-lua-auto-updater/main/auto-updater.lua",
        function(result, headers, status_code)
            local function parse_auto_update_result(result, headers, status_code)
                local error_prefix = "Error downloading auto-updater: "
                if status_code ~= 200 then util.toast(error_prefix..status_code, TOAST_ALL) return false end
                if not result or result == "" then util.toast(error_prefix.."Found empty file.", TOAST_ALL) return false end
                filesystem.mkdir(filesystem.scripts_dir() .. "lib")
                local file = io.open(filesystem.scripts_dir() .. "lib\\auto-updater.lua", "wb")
                if file == nil then util.toast(error_prefix.."Could not open file for writing.", TOAST_ALL) return false end
                file:write(result) file:close() util.toast("Successfully installed auto-updater lib", TOAST_ALL) return true
            end
            auto_update_complete = parse_auto_update_result(result, headers, status_code)
        end, function() util.toast("Error downloading auto-updater lib. Update failed to download.", TOAST_ALL) end)
    async_http.dispatch() local i = 1 while (auto_update_complete == nil and i < 40) do util.yield(250) i = i + 1 end
    if auto_update_complete == nil then error("Error downloading auto-updater lib. HTTP Request timeout") end
    auto_updater = require("auto-updater")
end
if auto_updater == true then error("Invalid auto-updater lib. Please delete your Stand/Lua Scripts/lib/auto-updater.lua and try again") end

auto_updater.run_auto_update({
    source_url="https://raw.githubusercontent.com/Game-Crunch/GameCrunchScript/main/GameCrunchScript.lua",
    script_relpath=SCRIPT_RELPATH,
    verify_file_begins_with=""
})

-- End of auto-updater


util.toast("GameCrunchScript Version 5.5-S")  
util.require_natives(1640181023)
menu.divider(menu.my_root(), "GameCrunch Script")

local self = menu.list(menu.my_root(), "Self", {}, "Features relating to your character") -- Self root
local online = menu.list(menu.my_root(), "Online", {}, "Features relating to GTA-online") -- Online root
local credits = menu.list(menu.my_root(), "Credits", {}, "Just credits") -- Credits root


-- Functions

function loadModel(model) 
    STREAMING.REQUEST_MODEL(model)
    while STREAMING.HAS_MODEL_LOADED(model) == false do 
        STREAMING.REQUEST_MODEL(model)
        util.yield(0)
    end
end

-- =================================================
-- Self Features

menu.action(self, "Boost pad", {}, "Spawns a boost pad in-front of yourself", function() 
    local coords = players.get_position(players.user())
    coords.z = coords.z - 0.2
    local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    local heading = ENTITY.GET_ENTITY_HEADING(player)
    local heading = heading + 80
    local boostpad = entities.create_object(3287988974, coords)
    ENTITY.SET_ENTITY_HEADING(boostpad, heading)
end)

menu.action(self, "Horizontal boost pad", {}, "Spawns a horizontal boost pad in-front of yourself", function() 
    local coords = players.get_position(players.user())
    coords.z = coords.z - 0.6
    local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    local heading = ENTITY.GET_ENTITY_HEADING(player)
    local boostpad = entities.create_object(-388593496, coords)
    ENTITY.SET_ENTITY_HEADING(boostpad, heading)
end)

menu.toggle_loop(self, "Fireworks", {}, "Creates fireworks above you", function()
    local coords = players.get_position(players.user())
    local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(coords.x, coords.y, coords.z+1, coords.x, coords.y, coords.z+10, 1, true, 2138347493, playerPed, true, false, 50)
    util.yield(1500)
end)

menu.toggle_loop(self, "Never wanted", {}, "Alternative to locking your wanted level to zero, kind of useless but whatever", function()
util.set_local_player_wanted_level(0)
end)


-- =================================================
-- Online Features

menu.toggle_loop(online, "Script Host Roulette", {}, "Will probably break the session", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        menu.trigger_commands("givesh" .. players.get_name(pid))
        util.yield(1500)
    end
end)

-- RP Party Drop

menu.toggle_loop(online, "RP drop party", {}, "RP drop all nearby players", function()
for _, aPed in ipairs(entities.get_all_peds_as_handles()) do
    local pedType = PED.GET_PED_TYPE(aPed)
    if pedType < 4 then
        local selfCoords = players.get_position(players.user())
        local coords = ENTITY.GET_ENTITY_COORDS(aPed, true)
        local figure = MISC.GET_HASH_KEY("vw_prop_vw_colle_prbubble")
        loadModel(figure)
        OBJECT.CREATE_AMBIENT_PICKUP(-1009939663, coords.x, coords.y, coords.z+1.5, 0, 1, figure, false, true)
        util.yield(partyDropDelay)
    end
end
end)

partyDropDelay = 1500
menu.slider(online, "Party drop delay", {}, "Delay for the drop speed (in ms)", 100, 10000, 1500, 100, function(partyDelay)
    partyDropDelay = partyDelay
end)


----------

menu.action(online, "Animal cruelty", {}, "Explode all nearby animals", function()
    animalFound = false
    for i, aPed in pairs(entities.get_all_peds_as_handles()) do 
       if PED.IS_PED_HUMAN(aPed) ~= true then 
        animalFound = true
        local pedPos = ENTITY.GET_ENTITY_COORDS(aPed)
        FIRE.ADD_EXPLOSION(pedPos.x, pedPos.y, pedPos.z, 0, 1, true, false, 0, false)
       end
    end
    if animalFound == false then 
        util.toast("No animal's found")
    end
end)

menu.toggle_loop(online, "Honk honk", {}, "Cause all nearby vehicles to activate there horns", function() 
    AUDIO.SET_AGGRESSIVE_HORNS(true)
    for i, vehs in pairs(entities.get_all_vehicles_as_handles()) do
        VEHICLE.START_VEHICLE_HORN(vehs, 1000, 0, false)
    end
    util.yield(1000)
end)

-- =======================================
-- Detections

detections = menu.list(online, "Detections", {}, "")

menu.toggle_loop(detections, "High-Money", {}, "Detects people with over 600 million", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        if players.get_money(pid) > 600000000 then 
            util.draw_debug_text(players.get_name(pid) .. " has modded money")
            if kickHighMoney then 
                menu.trigger_commands("kick".. players.get_name(pid))
                util.toast(players.get_name(pid).. " was kicked for having high money.")
            end
        end
    end
end)

menu.toggle(detections, "Kick people with high money", {}, "The high-money detection has to be enabled.", function(toggle)
    kickHighMoney = toggle
end)

menu.toggle_loop(detections, "High-Level", {}, "Detects people over level 4000", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        if players.get_rank(pid) > 4000 then 
            util.draw_debug_text(players.get_name(pid) .. " has a moddel level")
            if kickHighLevel then 
                menu.trigger_commands("kick".. players.get_name(pid))
                util.toast(players.get_name(pid).. " was kicked for having a high level.")
            end 
        end
    end
end)

menu.toggle(detections, "Kick people with a high level", {}, "The high-level detection has to be enabled.", function(toggle)
    kickHighLevel = toggle
end)

menu.action(detections, "Blocked Network Event Check", {}, "Sends a take-over request to people in a vehicle, if they block it triggers a detection within Stand, however other modders will also detect you", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
    end
end)

menu.toggle_loop(detections, "Voice chat detection", {}, "Notifies you of people using voice-chat, not a modder detection.", function()
    for _, pid in ipairs(players.list(true, true, true)) do
        if NETWORK.NETWORK_IS_PLAYER_TALKING(pid) then 
            util.toast(players.get_name(pid) " is using voice-chat")
        end
    end
end)

menu.toggle_loop(detections, "French", {}, "Notifies you if a french person is detected", function()
    for _, pid in ipairs(players.list(true, true, true)) do
        if players.get_language(pid) == 1 then
            util.toast(players.get_name(pid).. " is French!")
        end
    end
end)

-- ===============

-- Join the discord
menu.hyperlink(menu.my_root(), "Join the Republic of GameCrunch", "https://discord.gg/qjbBDtaxjX")

-- =================================================
-- Credits
menu.action(credits, "SoulReaper", {}, "Helped in #programming", function()
end)

menu.action(credits, "Lance", {}, "I looked at LanceScript to figure out how to spawn objects", function()
end)

menu.action(credits, "Wiri", {}, "Looked at how WiriScript applied vehicle boost", function()
end)
-- =================================================

-- Other Player Features

players.on_join(function(pid)

    -- Root setup
    menu.divider(menu.player_root(pid), "GameCrunch Script")
    local playerRoot = menu.list(menu.player_root(pid), "GameCrunch Script", {"gcScript"}, "")
    local friendly = menu.list(playerRoot, "Friendly", {}, "")
    local trolling = menu.list(playerRoot, "Trolling", {}, "")

    -- ==================
    -- Friendly features

    menu.action(friendly, "Boost pad", {}, "Spawns a boost pad in-front of the player", function() 
        local coords = players.get_position(pid)
        coords.z = coords.z - 0.2
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local heading = ENTITY.GET_ENTITY_HEADING(player)
        local heading = heading + 80
        local boostpad = entities.create_object(3287988974, coords)
        ENTITY.SET_ENTITY_HEADING(boostpad, heading)
    end)

    menu.action(friendly, "Horizontal Boost pad", {}, "Spawns a horizontal boost pad in-front of the player", function() 
        local coords = players.get_position(pid)
        coords.z = coords.z - 0.6
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local heading = ENTITY.GET_ENTITY_HEADING(player)
        local boostpad = entities.create_object(-388593496, coords)
        ENTITY.SET_ENTITY_HEADING(boostpad, heading)
    end)
    
    menu.toggle_loop(friendly, "Give horn boost", {}, "Give the target horn-boost", function()  
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player, false)
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle)
        local force = ENTITY.GET_ENTITY_FORWARD_VECTOR(vehicle)
        force.x = force.x * 20
        force.y = force.y * 20
        force.z = force.z * 20
        while PLAYER.IS_PLAYER_PRESSING_HORN(pid) == true do 
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle)
            ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, force.x, force.y, force.z, 0.0, 0.0, 0.0, 1, false, true, true, true, true)
            util.yield(100)
        end 
    end)
    
    menu.toggle_loop(friendly, "Auto-give Script host", {}, "", function()
        while players.get_script_host() ~= pid do 
            menu.trigger_commands("givesh" .. players.get_name(pid))
            util.yield(10)
        end
        util.yield(500)
    end)


    menu.action(friendly, "Repair vehicle", {}, "Repair the targets vehicle, if target isn't in vehicle then it repairs there last vehicle", function()    
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(player, true)
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(playerVehicle)
        VEHICLE.SET_VEHICLE_FIXED(playerVehicle)
    end)

    -- RP DROP

    local dropRP = menu.list(friendly, "Drop RP", {}, "")

    menu.slider(dropRP, "RP drop delay", {}, "Delay for the RP drop", 100, 10000, 1500, 100, function(rpDelay)
        rpDropDelay = rpDelay
    end)
    rpDropDelay = 1500

    menu.toggle_loop(dropRP, "Drop RP", {}, "RP drop but with adjustable delay", function() 
        local coords = players.get_position(pid)
        coords.z = coords.z + 1.5
        local figure = MISC.GET_HASH_KEY("vw_prop_vw_colle_prbubble")
        loadModel(figure)
        OBJECT.CREATE_AMBIENT_PICKUP(-1009939663, coords.x, coords.y, coords.z, 0, 1, figure, false, true)
        util.yield(rpDropDelay)
    end)

    -- Card drop 

    local dropCard = menu.list(friendly, "Drop Cards", {}, "")

    menu.slider(dropCard, "Card drop delay", {}, "Delay for the Card drop", 100, 10000, 1500, 100, function(cardDelay)  
        cardDropDelay = cardDelay
    end)
    cardDropDelay = 1500

    menu.toggle_loop(dropCard, "Drop Cards", {}, "Players can only pickup 54 cards per session", function()
        local coords = players.get_position(pid)
        coords.z = coords.z + 1.5
        local card = MISC.GET_HASH_KEY("vw_prop_vw_lux_card_01a")
        loadModel(card)
        OBJECT.CREATE_AMBIENT_PICKUP(-1009939663, coords.x, coords.y, coords.z, 0, 1, card, false, true)
        util.yield(cardDropDelay)
    end)

-- =================================================
    -- Trolling features

    menu.action(trolling, "Asteroid Smash", {}, "Crush the player with an asteroid", function() 
        local coords = players.get_position(pid)
        coords.z = coords.z + 15.0
        local asteroid = entities.create_object(3751297495, coords)
        ENTITY.SET_ENTITY_DYNAMIC(asteroid, true)
    end)

    menu.action(trolling, "Punishment roulette", {}, "Choses a randomly selected punishment", function()
    local chosenPunishment = math.random(5)
    if chosenPunishment == 1 then 
        util.toast(players.get_name(pid).. " will be rag-dolled!")
        local coords = players.get_position(pid)
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 11, 1, false, true, 0, true) 
    end
    if chosenPunishment == 2 then 
        util.toast(players.get_name(pid).." will be struck by a rocket!")
        local coords = players.get_position(pid)
        local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(coords.x, coords.y, coords.z+15, coords.x, coords.y, coords.z, 100, true, -1312131151, playerPed, true, false, 50)
    end
    if chosenPunishment == 3 then 
        util.toast(players.get_name(pid).." has had there vehicle deleted!")
        local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local playerVehicle = PED.GET_VEHICLE_PED_IS_IN(playerPed, true)
        entities.delete_by_handle(playerVehicle)
    end
    if chosenPunishment == 4 then 
        util.toast(players.get_name(pid).." has been set on fire!")
        local coords = players.get_position(pid)
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 12, 0, true, false, 0, false)
    end
    if chosenPunishment == 5 then 
        util.toast(players.get_name(pid).." has been spared!")
    end
    end)

    menu.action(trolling, "Vehicle slow-down", {}, "Spawns a vehicle slow-down pad in-front of them", function() 
        local coords = players.get_position(pid)
        coords.z = coords.z - 0.4
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local heading = ENTITY.GET_ENTITY_HEADING(player)
        local heading = heading + 80
        local boostpad = entities.create_object(-227275508, coords)
        ENTITY.SET_ENTITY_HEADING(boostpad, heading)
    end)

    menu.action(trolling, "UFO Lift", {}, "Use a UFO to pull them up for a second", function()  -- probaly could improve by EMPing the vehicle instead and figuring out how to have that beam
        local coords = players.get_position(pid)
        coords.z = coords.z + 63
        local ufoModel = MISC.GET_HASH_KEY("p_spinning_anus_s")
        local ufo = entities.create_object(ufoModel, coords)
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player, false)

        if PED.IS_PED_IN_VEHICLE(player, vehicle, false) then 
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle)
            VEHICLE.BRING_VEHICLE_TO_HALT(vehicle, 3, 4, false)
            VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, false, true, true)
            ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0.0, 65, 0.0, 0.0, 0.0, 1, false, true, true, true, true)
            util.yield(6000)
            entities.delete_by_handle(ufo)
        else
            util.toast("Target is not in a vehicle") 
    end
    end)

    menu.toggle_loop(trolling, "Random engine shut-offs", {}, "Randomly turns target vehicle off", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(player, false)
        local random = math.random(1, 10)
        if random >= 8 then 
            VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, false, true, false)
            VEHICLE.BRING_VEHICLE_TO_HALT(vehicle, 9, 1, false)
            util.yield(50)
        end
        util.yield(2500)
    end)

    menu.toggle_loop(trolling, "Rocket impacts", {}, "Spawn rockets above target", function()
        local coords = players.get_position(pid)
        local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(coords.x, coords.y, coords.z+10, coords.x, coords.y, coords.z, 1, true, -1312131151, playerPed, true, false, 50)
        util.yield(1500)
    end)

    menu.toggle_loop(trolling, "Ragdoll loop", {}, "Keeps target ragdolled", function()
        local coords = players.get_position(pid)
        coords.z = coords['z'] - 2.0
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 11, 1, false, true, 0, true)
        util.yield(10)
    end)

    menu.action(trolling, "Ragdoll", {}, "Ragdoll the target once", function()
        local coords = players.get_position(pid)
        coords.z = coords['z'] - 2.0
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 11, 1, false, true, 0, true)
    end)

    menu.toggle_loop(trolling, "Flame loop", {}, "Spam fire beneath the target", function()
        local coords = players.get_position(pid)
        coords.z = coords['z'] - 2.0
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 12, 1, true, false, 0, false)
        util.yield(25)
    end)

    menu.toggle_loop(trolling, "Water Jet loop", {}, "Spam water jets beneath the target", function()
        local coords = players.get_position(pid)
        coords.z = coords['z'] - 2.0
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 13, 1, true, false, 0, false)
        util.yield(25)
    end)

    menu.toggle_loop(trolling, "Crap trail", {}, "", function()
        local coords = players.get_position(pid)
        coords.z = coords['z'] + 1.5
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 35, 0, false, false, 0, false)
        util.yield(65)
    end)

    menu.toggle_loop(trolling, "Flame path", {}, "They better run", function()
        local coords = players.get_position(pid)
        --coords.z = coords['z'] + 1.5
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 38, 0, false, false, 0, false)
        util.yield(65)
    end)

    menu.toggle_loop(trolling, "Script Event Spam", {}, "Won't really do anything against good menus", function()
    local scriptEvents = {-910497748, 243072129, -1322731185, 434937615, -168599209, 392606458, 1858712297, -1891171016} -- Most of these probaly do nothing because no parameters, but CBAed to sort through them
        for i, se in pairs(scriptEvents) do 
            util.trigger_script_event(1 << pid, {se, pid})
            util.yield(10)
        end

    end)

    menu.action(trolling, "Kill passive-mode player", {}, "", function()
        local coords = players.get_position(pid)
        local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        coords.z = coords.z + 5
        local playerCar = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)
        if playerCar > 0 then
            entities.delete_by_handle(playerCar)
        end
        local carHash = util.joaat("dukes2")
        loadModel(carHash)
        local car = entities.create_vehicle(carHash, coords, 0)
        ENTITY.SET_ENTITY_VISIBLE(car, false, 0)
        ENTITY.APPLY_FORCE_TO_ENTITY(car, 1, 0.0, 0.0, -65, 0.0, 0.0, 0.0, 1, false, true, true, true, true)
    end)

    -- ================================================================================
    -- SOUNDS

    local sounds = menu.list(trolling, "Sounds", {}, "")

    menu.toggle_loop(sounds, "Hurt there ears", {}, "Do a little trolling", function()
        local coords = players.get_position(pid)
        AUDIO.PLAY_SOUND_FROM_COORD(-1, "BED", coords.x, coords.y, coords.z, "WASTEDSOUNDS", true, 5, false)
        AUDIO.PLAY_SOUND_FROM_COORD(-1, "Crash", coords.x, coords.y, coords.z, "DLC_HEIST_HACKING_SNAKE_SOUNDS", true, 5, false)
        AUDIO.PLAY_SOUND_FROM_COORD(-1, "BASE_JUMP_PASSED", coords.x, coords.y, coords.z, "HUD_AWARDS", true, 5, false)
        util.yield(20)
    end)

    menu.toggle_loop(sounds, "Wasted Sound", {}, "", function()
        local coords = players.get_position(pid)
        AUDIO.PLAY_SOUND_FROM_COORD(1, "BED", coords.x, coords.y, coords.z, "WASTEDSOUNDS", true, 5, false)
        util.yield(5800)
    end)

    menu.toggle_loop(sounds, "Yacht Horn", {}, "", function()
        local coords = players.get_position(pid)
        AUDIO.PLAY_SOUND_FROM_COORD(-1, "Horn", coords.x, coords.y, coords.z, "DLC_Apt_Yacht_Ambient_Soundset", true, 5, false)
        util.yield(3000)
    end)

    menu.toggle_loop(sounds, "Buzz", {}, "", function()
        local coords = players.get_position(pid)
        AUDIO.PLAY_SOUND_FROM_COORD(-1, "Crash", coords.x, coords.y, coords.z, "DLC_HEIST_HACKING_SNAKE_SOUNDS", true, 5, false)
        util.yield(1700)
    end)

    menu.toggle_loop(sounds, "Mission Sucess sound", {}, "", function()
        local coords = players.get_position(pid)
        AUDIO.PLAY_SOUND_FROM_COORD(1, "BASE_JUMP_PASSED", coords.x, coords.y, coords.z, "HUD_AWARDS", true, 5, false)
        util.yield(1250)
    end)

    -- ====================================================================================

    menu.action(trolling, "Announce based-level", {}, "", function()
    local basedLevel = math.random(100)
    local basedPercentage = players.get_name(pid).. " Is ".. basedLevel.. "% based"
    chat.send_message(basedPercentage, false, true, true)
    end)

    menu.action(trolling, "Tell them to kill themselves", {}, "POV: lost a discord argument", function() 
    local kys = "Hey " .. players.get_name(pid) .. ' you should kill yourself NOW!' 
    chat.send_message(kys, false, true, true)
    end)

end)
players.dispatch_on_join()
util.keep_running()
