--[[
    MSET9-GM9
    v1.0.0 beta
    last updated: 2025-04-22
    author: ManiacOfHomebrew
]]

local function userExit()
    ui.show_png('9:/mset9-gm9/scriptExit.png')
    ui.echo('You pressed (B) so the script has exited.\nThe console will now power off.')
    sys.power_off()
end

local function swapSd(message)
    local success, result = pcall(fs.sd_switch, message)
    if not success then
        userExit()
        return
    end
    if not fs.sd_is_mounted() then
        ui.show_png('9:/mset9-gm9/error.png')
        ui.echo("Error 15: The target console's SD card\ncouldn't be read.\nEnsure the SD card is formatted to\nFAT32 and is inserted properly.\nThis may also be a sign of corruption.")
        ui.show_png('9:/mset9-gm9/scriptExit.png')
        ui.echo('The script has exited due to an error.\nPress (A) to power off the console.')
        sys.power_off()
        return
    end
end

local function is3DSID(name)
    return name:match('^[0-9A-Fa-f]+$') and name:len() == 32
end


local haxState = 0
local consoleNames = {
    "Old 3DS/2DS, 11.8.0 to 11.17.0",
    "New 3DS/2DS, 11.8.0 to 11.17.0",
    "Old 3DS/2DS, 11.4.0 to 11.7.0",
    "New 3DS/2DS, 11.4.0 to 11.7.0"
};
local haxID1s = {
    "\u{C001}\u{E28F}\u{FF1C}\u{E12F}\u{9911}\u{480B}\u{4685}\u{6569}\u{A107}\u{2201}\u{4B04}\u{4798}\u{4668}\u{4659}\u{AAC0}\u{1C17}\u{4643}\u{4C02}\u{47A0}\u{47B8}\u{A071}\u{805}\u{CE99}\u{804}sdmc\u{9000}\u{80A}b9",
    "\u{C001}\u{E28F}\u{FF1C}\u{E12F}\u{9911}\u{480B}\u{4685}\u{6569}\u{A107}\u{2201}\u{4B04}\u{4798}\u{4668}\u{4659}\u{AAC0}\u{1C17}\u{4643}\u{4C02}\u{47A0}\u{47B8}\u{A071}\u{805}\u{CE5D}\u{804}sdmc\u{9000}\u{80A}b9",
    "\u{C001}\u{E28F}\u{FF1C}\u{E12F}\u{9911}\u{480B}\u{4685}\u{6569}\u{A107}\u{2201}\u{4B04}\u{4798}\u{4668}\u{4659}\u{AAC0}\u{1C17}\u{4643}\u{4C02}\u{47A0}\u{47B8}\u{9E49}\u{805}\u{CC99}\u{804}sdmc\u{9000}\u{80A}b9",
    "\u{C001}\u{E28F}\u{FF1C}\u{E12F}\u{9911}\u{480B}\u{4685}\u{6569}\u{A107}\u{2201}\u{4B04}\u{4798}\u{4668}\u{4659}\u{AAC0}\u{1C17}\u{4643}\u{4C02}\u{47A0}\u{47B8}\u{9E45}\u{805}\u{CC81}\u{804}sdmc\u{9000}\u{80A}b9"
}


if not fs.sd_is_mounted() then
    ui.echo("Error 02G: There is no SD card mounted.\n(You went out of your way to\nget here, didn't you?)")
    ui.echo("The script has exited due to an error.\nPress (A) to power off the console.")
    sys.power_off()
    return
end
local necessaryScriptFiles = {
    '0:/gm9/luascripts/MSET9-GM9.lua',
    '0:/mset9-gm9/welcome.png',
    '0:/mset9-gm9/unmoddedSdSwap.png',
    '0:/mset9-gm9/error.png',
    '0:/mset9-gm9/info.png',
    '0:/mset9-gm9/warning.png',
    '0:/mset9-gm9/scriptExit.png',
    '0:/mset9-gm9/inputConsoleInfo.png'
}
for _, file in ipairs(necessaryScriptFiles) do
    if not fs.exists(file) then
        if fs.exists('0:/mset9-gm9/error.png') then
            ui.show_png('0:/mset9-gm9/error.png')
        end
        ui.echo("Error 03G: The script is missing files.\nPlease redo Section I of the guide.")
        if fs.exists('0:/mset9-gm9/scriptExit.png') then
            ui.show_png('0:/mset9-gm9/scriptExit.png')
        end
        ui.echo('The script has exited due to an error.\nPress (A) to power off the console.')
        sys.power_off()
        return
    end
end

ui.show_png('0:/mset9-gm9/welcome.png')
local success, result = pcall(fs.copy,'0:/mset9-gm9', '9:/mset9-gm9', {overwrite = true, no_cancel = true, recursive = true})
if not success then
    ui.show_png('9:/mset9-gm9/error.png')
    ui.echo("Error 04G: Failed to copy files to RAM.\n(How?)\nReason:\n" .. result)
    ui.show_png('9:/mset9-gm9/scriptExit.png')
    ui.echo('The script has exited due to an error.\nPress (A) to power off the console.')
    sys.power_off()
    return
end

if not ui.ask('MSET9-GM9 resources loaded. Press (A) to continue.\n \nPress (B) to exit the script.') then
    userExit()
    return
end
ui.show_png('9:/mset9-gm9/unmoddedSdSwap.png')
swapSd('Remove the SD card from this console and insert the\nSD card from the unmodded console.')

local necessaryTargetFiles = {"SafeB9S.bin", "b9", "boot.firm", "boot.3dsx", "boot9strap/boot9strap.firm", "boot9strap/boot9strap.firm.sha"}
for _, file in ipairs(necessaryTargetFiles) do
    if not fs.exists('0:/' .. file) then
        ui.show_png('9:/mset9-gm9/error.png')
        ui.echo("Error 07: One or more files from the target\nconsole's SD card are missing.\nPlease redo Section I of the guide.")
        ui.show_png('9:/mset9-gm9/scriptExit.png')
        ui.echo('The script has exited due to an error.\nPress (A) to power off the console.')
        sys.power_off()
        return
    end
end
-- Check SD card for Nintendo 3DS folder
while not fs.exists('0:/Nintendo 3DS') do
    ui.show_png('9:/mset9-gm9/error.png')
    ui.echo("Error 01: Couldn't find the Nintendo 3DS folder.\nOn the next screen, eject the SD card and\ninsert it into the unmodded console.\nTurn it on and off again, then insert it\ninto this console.")
    swapSd('Waiting for SD to be reinserted...')
end

ui.show_png('9:/mset9-gm9/info.png')
ui.echo('On the following screen, type in the combo.\n \nYou can safely ignore the warning\nthat says "!THIS IS NOT RECOMMENDED!"')
if not fs.allow('0:/Nintendo 3DS') then
    ui.show_png('9:/mset9-gm9/scriptExit.png')
    ui.echo('You did not provide access to the\nNintendo 3DS folder.\n \nThe console will now power off.')
    sys.power_off()
    return
end

ui.show_png('9:/mset9-gm9/inputConsoleInfo.png')
local consoleSelection = ui.ask_selection("What is your target console model and version?\nOld 3DS has two shoulder buttons (L and R)\nNew 3DS has four shoulder buttons (L, R, ZL, ZR)", consoleNames)
if not consoleSelection then
    userExit()
end

-- Check ID0s
local id0list = fs.list_dir('0:/Nintendo 3DS')
local id0count = 0
local id0name = ''
for _, id0 in ipairs(id0list) do
    if id0.type == 'dir' and is3DSID(id0.name) then
        id0count = id0count + 1
        id0name = id0.name
    end
end
if id0count ~= 1 then
    ui.show_png('9:/mset9-gm9/error.png')
    ui.echo("Error 04: You don't have 1 ID0 in your\nNintendo 3DS folder, you have " .. id0count .. "!")
    ui.show_qr("Consult:\nhttps://wiki.hacks.guide/wiki/3DS:MID0\nPress (A) to continue.", 'https://wiki.hacks.guide/wiki/3DS:MID0')
    ui.show_png('9:/mset9-gm9/scriptExit.png')
    ui.echo('The script has exited due to an error.\nPress (A) to power off the console.')
    sys.power_off()
    return
end

--Check ID1s
local id1list = fs.list_dir('0:/Nintendo 3DS/' .. id0name)
local id1count = 0
local id1name = ''
for _, id1 in ipairs(id1list) do
    if id1.type == 'dir' then
        if is3DSID(id1.name) or (id1.name:sub(33) == "_user-id1" and is3DSID(id1.name:sub(1,32))) then
            id1count = id1count + 1
            id1name = id1.name
        elseif id1.name:find('sdmc') and id1.name:len() == 84 then
            -- Check MSET9 haxState
            local currentHaxID1index = 0
            for i, haxID1 in ipairs(haxID1s) do
                if id1.name == haxID1 then
                    currentHaxID1index = i
                    break
                end
            end
            if currentHaxID1index == 0 then
                ui.show_png('9:/mset9-gm9/warning.png')
                ui.echo("Unrecognized/duplicate hacked ID1\nin ID0 folder, removing!")
                fs.remove('0:/Nintendo 3DS/' .. id0name .. '/' .. id1.name, {recursive = true})
            elseif currentHaxID1index ~= consoleSelection then
                ui.show_text("Earlier, you selected:\n" .. consoleNames[currentHaxID1index] .. "\n \nNow, you selected:\n" .. consoleNames[consoleSelection] .. "\n \nPlease re-select one of the above for your target console's\nmodel and version.")
                local userInput = ui.ask_selection("Error 03: Don't change console model/version\nin the middle of MSET9!\n \nPlease read the above and select\none of the options below.", {consoleNames[currentHaxID1index], consoleNames[consoleSelection]})
                if not userInput then
                    userExit()
                    return
                end
                if userInput == 1 then
                    consoleSelection = currentHaxID1index
                elseif userInput == 2 then
                    local success, result = pcall(fs.move, '0:/Nintendo 3DS/' .. id0name .. '/' .. id1.name, '0:/Nintendo 3DS/' .. id0name .. '/' .. haxID1s[consoleSelection], {overwrite = true, no_cancel = true})
                    if not success then
                        ui.show_png('9:/mset9-gm9/error.png')
                        ui.echo("Failed to change console version.\nReason:\n" .. result)
                        ui.show_png('9:/mset9-gm9/scriptExit.png')
                        ui.echo('The script has exited due to an error.\nPress (A) to power off the console.')
                        sys.power_off()
                        return
                    end
                end
            end
        end
    end
end
if id1count ~= 1 then
    ui.show_png('9:/mset9-gm9/error.png')
    ui.echo("Error 05: You don't have 1 ID1 in your\nNintendo 3DS folder, you have " .. id1count .. "!")
    ui.show_qr("Consult:\nhttps://wiki.hacks.guide/wiki/3DS:MID1\nPress (A) to continue.", 'https://wiki.hacks.guide/wiki/3DS:MID1')
    ui.show_png('9:/mset9-gm9/scriptExit.png')
    ui.echo('The script has exited due to an error.\nPress (A) to power off the console.')
    sys.power_off()
    return
end