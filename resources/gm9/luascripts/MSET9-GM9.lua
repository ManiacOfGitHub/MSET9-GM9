--[[
    MSET9-GM9
    v1.0.0 beta
    last updated: 2025-04-22
    author: ManiacOfHomebrew
]]

local function userExit()
    ui.show_png('0:/mset9-gm9/scriptExit.png')
    ui.echo('You pressed (B) so the script has exited.\nThe console will now power off.')
    sys.power_off()
end

local function scriptExit()
    ui.show_png('0:/mset9-gm9/scriptExit.png')
    ui.echo('Press (A) to power off the console.')
    sys.power_off()
end

local function is3DSID(name)
    return name:match('^[0-9A-Fa-f]+$') and name:len() == 32
end


local haxState = 1
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
local hackedId1path
local titleDbsGood = false
local menuExtdataGood = false
local miiExtdataGood = false

if not fs.sd_is_mounted() then
    ui.echo("Error 02G: There is no SD card mounted.\n(You went out of your way to\nget here, didn't you?)")
    ui.echo("The script has exited due to an error.\nPress (A) to power off the console.")
    sys.power_off()
    return
end
local necessaryScriptFiles = {
    '0:/gm9/luascripts/MSET9-GM9.lua',
    '0:/mset9-gm9/welcome.png',
    '0:/mset9-gm9/error.png',
    '0:/mset9-gm9/info.png',
    '0:/mset9-gm9/warning.png',
    '0:/mset9-gm9/scriptExit.png',
    '0:/mset9-gm9/inputConsoleInfo.png',
    '0:/mset9-gm9/mset9NotCreated.png',
    '0:/mset9-gm9/sanityCheckFailed.png',
    '0:/mset9-gm9/ready.png',
    '0:/mset9-gm9/triggerFileRemoved.png',
    '0:/mset9-gm9/triggerFileInjected.png',
    '0:/mset9-gm9/mset9Removed.png',
    '0:/mset9-gm9/mset9Created.png'
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

if not ui.ask('Welcome to MSET9-GM9.\n \nPress (A) to continue.\nPress (B) to exit the script.') then
    userExit()
    return
end

local necessaryTargetFiles = {"SafeB9S.bin", "b9", "boot.firm", "boot.3dsx", "boot9strap/boot9strap.firm", "boot9strap/boot9strap.firm.sha"}
for _, file in ipairs(necessaryTargetFiles) do
    if not fs.exists('0:/' .. file) then
        ui.show_png('0:/mset9-gm9/error.png')
        ui.echo("Error 07: One or more files from the target\nconsole's SD card are missing.\nPlease redo Section I of the guide.")
        ui.show_png('0:/mset9-gm9/scriptExit.png')
        ui.echo('The script has exited due to an error.\nPress (A) to power off the console.')
        sys.power_off()
        return
    end
end
-- Check SD card for Nintendo 3DS folder
if not fs.exists('0:/Nintendo 3DS') do
    ui.show_png('0:/mset9-gm9/error.png')
    ui.echo("Error 01: Couldn't find the Nintendo 3DS folder.\nEject the SD card and insert it into the\nunmodded console.\nTurn it on and off again, then re-run this script.")
    ui.show_png('0:/mset9-gm9/scriptExit.png')
    ui.echo('The script has exited due to an error.\nPress (A) to power off the console.')
    sys.power_off()
    return
end

ui.show_png('0:/mset9-gm9/info.png')
ui.echo('On the following screen, type in the combo.\n \nYou can safely ignore the warning\nthat says "!THIS IS NOT RECOMMENDED!"')
if not fs.allow('0:/Nintendo 3DS') then
    ui.show_png('0:/mset9-gm9/scriptExit.png')
    ui.echo('You did not provide access to the\nNintendo 3DS folder.\n \nThe console will now power off.')
    sys.power_off()
    return
end

ui.show_png('0:/mset9-gm9/inputConsoleInfo.png')
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
    ui.show_png('0:/mset9-gm9/error.png')
    ui.echo("Error 04: You don't have 1 ID0 in your\nNintendo 3DS folder, you have " .. id0count .. "!")
    ui.show_qr("Consult:\nhttps://wiki.hacks.guide/wiki/3DS:MID0\nPress (A) to continue.", 'https://wiki.hacks.guide/wiki/3DS:MID0')
    ui.show_png('0:/mset9-gm9/scriptExit.png')
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
            -- Check for MSET9 ID1
            local currentHaxID1index = 0
            for i, haxID1 in ipairs(haxID1s) do
                if id1.name == haxID1 then
                    currentHaxID1index = i
                    break
                end
            end
            if currentHaxID1index == 0 then
                ui.show_png('0:/mset9-gm9/warning.png')
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
                        ui.show_png('0:/mset9-gm9/error.png')
                        ui.echo("Failed to change console version.\nReason:\n" .. result)
                        ui.show_png('0:/mset9-gm9/scriptExit.png')
                        ui.echo('The script has exited due to an error.\nPress (A) to power off the console.')
                        sys.power_off()
                        return
                    end
                end
            end
            -- MSET9 ID1 found
            hackedId1path = '0:/Nintendo 3DS/' .. id0name .. '/' .. id1.name

            -- Sanity check - check dbs
            local titleDbExists = fs.exists(hackedId1path .. '/dbs/title.db')
            local importDbExists = fs.exists(hackedId1path .. '/dbs/import.db')
            titleDbsGood = false
            if not titleDbExists or not importDbExists then
                fs.make_dummy_file(hackedId1path .. '/dbs/title.db', 0)
                fs.make_dummy_file(hackedId1path .. '/dbs/import.db', 0)
            else
                local titleDbInfo = fs.stat(hackedId1path .. '/dbs/title.db')
                local importDbInfo = fs.stat(hackedId1path .. '/dbs/import.db')
                if titleDbInfo.type == 'dir' or importDbInfo.type == 'dir' then
                    fs.remove(hackedId1path .. '/dbs/title.db', {recursive = true})
                    fs.remove(hackedId1path .. '/dbs/import.db', {recursive = true})
                    fs.make_dummy_file(hackedId1path .. '/dbs/title.db', 0)
                    fs.make_dummy_file(hackedId1path .. '/dbs/import.db', 0)
                elseif titleDbInfo.size == 0x31E400 and importDbInfo.size == 0x31E400 then
                    titleDbsGood = true
                end
            end
            -- Sanity check - HOME menu extdata
            for j, tid in ipairs({0x8F, 0x98, 0x82, 0xA1, 0xA9, 0xB1}) do
                if fs.exists(hackedId1path .. '/extdata/00000000/' .. string.format('%08X', tid)) then
                    menuExtdataGood = true
                    break
                end
            end
            -- Sanity check - Mii Maker extdata
            for j, tid in ipairs({0x217, 0x227, 0x207, 0x267, 0x277, 0x287}) do
                if fs.exists(hackedId1path .. '/extdata/00000000/' .. string.format('%08X', tid)) then
                    miiExtdataGood = true
                    break
                end
            end
            -- Sanity check
            local sanityCheckPassed = titleDbsGood and menuExtdataGood and miiExtdataGood

            -- haxState check
            if fs.exists(hackedId1path .. '/extdata/002F003A.txt') then
                haxState = 4
            elseif sanityCheckPassed then
                haxState = 3
            else
                haxState = 2
            end
        end
    end
end
if id1count ~= 1 then
    ui.show_png('0:/mset9-gm9/error.png')
    ui.echo("Error 05: You don't have 1 ID1 in your\nNintendo 3DS folder, you have " .. id1count .. "!")
    ui.show_qr("Consult:\nhttps://wiki.hacks.guide/wiki/3DS:MID1\nPress (A) to continue.", 'https://wiki.hacks.guide/wiki/3DS:MID1')
    ui.show_png('0:/mset9-gm9/scriptExit.png')
    ui.echo('The script has exited due to an error.\nPress (A) to power off the console.')
    sys.power_off()
    return
end

hackedId1path = '0:/Nintendo 3DS/' .. id0name .. '/' .. haxID1s[consoleSelection]


local function createHaxID1()
    ui.show_png('0:/mset9-gm9/warning.png')
    ui.echo("=== DISCLAIMER ===\n \nThis process will temporarily reset all your 3DS\ndata.\nAll your applications and themes will disappear.\nThis is perfectly normal, and if everything goes\nright, it will re-appear at the end of the process.\n \nStill, it is highly recommended to make a backup\nof your SD card's contents.\n(Especially the 'Nintendo 3DS' folder.)")
    if not ui.ask('Press (A) to continue.\nPress (B) to exit the script.') then
        userExit()
        return
    end
    ui.clear()
    local success, result = pcall(fs.mkdir, hackedId1path .. '/dbs')
    if not success then
        ui.show_png('0:/mset9-gm9/error.png')
        ui.echo("Failed to create hacked ID1!\nReason:\n" .. result)
        return
    end
    for _, file in ipairs({'title.db', 'import.db'}) do
        local success, result = pcall(fs.make_dummy_file, hackedId1path .. '/dbs/' .. file, 0)
        if not success then
            ui.show_png('0:/mset9-gm9/error.png')
            ui.echo("Failed to create " .. file .. "!\nReason:\n" .. result)
            return
        end
    end
    if id1name:len() == 32 then
        local success, result = pcall(fs.move, '0:/Nintendo 3DS/' .. id0name .. '/' .. id1name, '0:/Nintendo 3DS/' .. id0name .. '/' .. id1name .. '_user-id1', {no_cancel = true})
        if not success then
            ui.show_png('0:/mset9-gm9/error.png')
            ui.echo("Failed to backup ID1!\nReason:\n" .. result)
            return
        end
    end
    ui.show_png('0:/mset9-gm9/mset9Created.png')
    ui.echo("Created hacked ID1.")
    scriptExit()
end

local function sanityReport()
    if titleDbsGood then
        ui.show_png('0:/mset9-gm9/info.png')
        ui.echo("Title database: OK!")
    else
        ui.show_png('0:/mset9-gm9/error.png')
        ui.echo("Title database: Not initialized!\n \nPower on the target console with the SD card inserted\nopen System Settings, and navigate to:\nData Management -> Nintendo 3DS -> Software -> Reset.\nThen, power off the console and re-run this script.")
    end
    if menuExtdataGood then
        ui.show_png('0:/mset9-gm9/info.png')
        ui.echo("HOME menu extdata: OK!")
    else
        ui.show_png('0:/mset9-gm9/error.png')
        ui.echo("HOME menu extdata: Missing!\n \nPower on the target console with the SD card inserted\nThen, power off the console and re-run this script.") 
    end
    if miiExtdataGood then
        ui.show_png('0:/mset9-gm9/info.png')
        ui.echo("Mii Maker extdata: OK!")
    else
        ui.show_png('0:/mset9-gm9/error.png')
        ui.echo("Mii Maker extdata: Missing!\n \nPower on the target console with the SD card inserted\nand launch Mii Maker.\nThen, power off the console and re-run this script.")
    end
end

local function createInject()
    if fs.exists(hackedId1path .. '/extdata/002F003A.txt') then
        ui.show_png('0:/mset9-gm9/error.png')
        ui.echo("Trigger file already injected.")
        return
    end
    
    local success, result = pcall(fs.write_file, hackedId1path .. '/extdata/002F003A.txt', 0, 'pls be haxxed mister arm9, thx')
    if not success then
        ui.show_png('0:/mset9-gm9/error.png')
        ui.echo("Failed to create trigger file!\nReason:\n" .. result)
        return
    end
    ui.show_png('0:/mset9-gm9/triggerFileInjected.png')
    ui.echo("MSET9 successfully injected!")
    scriptExit()
end

local function removeInject()
    if not fs.exists(hackedId1path .. '/extdata/002F003A.txt') then
        ui.show_png('0:/mset9-gm9/error.png')
        ui.echo("Trigger file already removed.")
        return
    end
    
    local success, result = pcall(fs.remove, hackedId1path .. '/extdata/002F003A.txt')
    if not success then
        ui.show_png('0:/mset9-gm9/error.png')
        ui.echo("Failed to remove trigger file!\nReason:\n" .. result)
        return
    end
    ui.show_png('0:/mset9-gm9/triggerFileRemoved.png')
    ui.echo("Removed trigger file.")
    haxState = 5
end

local function remove()
    if titleDbsGood and (not fs.exists('0:/Nintendo 3DS/' .. id0name .. '/' .. id1name .. '/dbs')) then
        pcall(fs.mkdir, '0:/Nintendo 3DS/' .. id0name .. '/' .. id1name .. '/dbs')
        pcall(fs.copy, hackedId1path .. '/dbs/title.db', '0:/Nintendo 3DS/' .. id0name .. '/' .. id1name .. '/dbs/title.db')
        pcall(fs.copy, hackedId1path .. '/dbs/import.db', '0:/Nintendo 3DS/' .. id0name .. '/' .. id1name .. '/dbs/import.db')
    end
    local success, result = pcall(fs.remove, hackedId1path, {recursive = true})
    if not success then
        ui.show_png('0:/mset9-gm9/error.png')
        ui.echo("Failed to delete hacked ID1.\nReason:\n" .. result)
        return
    end
    if id1name:len() ~= 32 then
        local success, result = pcall(fs.move, '0:/Nintendo 3DS/' .. id0name .. '/' .. id1name, '0:/Nintendo 3DS/' .. id0name .. '/' .. id1name:sub(1,32))
        if not success then
            ui.show_png('0:/mset9-gm9/error.png')
            ui.echo("Failed to rename original ID1.\nReason:\n" .. result)
            return
        end
    end
    haxState = 0
    ui.show_png('0:/mset9-gm9/mset9Removed.png')
    ui.echo("Successfully removed MSET9!")
    sys.power_off()
end

local function mainMenu()
    local menuOptions = {
        "1. Create MSET9 ID1",
        "2. Check MSET9 status",
        "3. Inject trigger file",
        "4. Remove trigger file"
    }
    if haxState ~= 4 then
        menuOptions[#menuOptions + 1] = "5. Remove MSET9"
    end
    if haxState == 1 then
        ui.show_png('0:/mset9-gm9/mset9NotCreated.png')
    elseif haxState == 2 then
        ui.show_png('0:/mset9-gm9/sanityCheckFailed.png')
    elseif haxState == 3 then
        ui.show_png('0:/mset9-gm9/ready.png')
    elseif haxState == 4 then
        ui.show_png('0:/mset9-gm9/triggerFileInjected.png')
    elseif haxState == 5 then
        ui.show_png('0:/mset9-gm9/triggerFileRemoved.png')
    else
        ui.clear() -- how did this happen?
    end
    local userInput = ui.ask_selection("Using " .. consoleNames[consoleSelection] .. "\nSelect an option or push (B) to exit script:", menuOptions)
    if not userInput then
        userExit()
        return
    elseif userInput == 1 then
        if haxState ~= 1 then
            ui.show_png('0:/mset9-gm9/info.png')
            ui.echo("MSET9 ID1 already exists.")
            return
        end
        createHaxID1()
    elseif userInput == 2 then
        if haxState == 1 then
            ui.show_png('0:/mset9-gm9/error.png')
            ui.echo("Can't do that now!")
            return
        end
        sanityReport()
    elseif userInput == 3 then
        if haxState ~= 3 then
            ui.show_png('0:/mset9-gm9/error.png')
            ui.echo("Can't do that now!")
            return
        end
        createInject()
    elseif userInput == 4 then
        if haxState < 3 then
            ui.show_png('0:/mset9-gm9/error.png')
            ui.echo("Can't do that now!")
            return
        end
        removeInject()
    elseif userInput == 5 then
        if haxState == 1 then
            ui.show_png('0:/mset9-gm9/error.png')
            ui.echo("Nothing to do.")
            return
        end
        if haxState == 4 then
            ui.show_png('0:/mset9-gm9/error.png')
            ui.echo("Can't do that now!")
            return
        end
        remove()
    end
end
while true do
    mainMenu()
end