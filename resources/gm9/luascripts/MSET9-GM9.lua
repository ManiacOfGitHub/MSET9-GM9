ui.show_png('0:/mset9-gm9/welcome.png')
fs.copy('0:/mset9-gm9', '9:/mset9-gm9', {overwrite = true, no_cancel = true, recursive = true})
ui.echo('MSET9-GM9 resources loaded.')
ui.show_png('9:/mset9-gm9/unmoddedSdSwap.png')
local success, result = pcall(fs.sd_switch, 'Remove the SD card from this console and insert the\nSD card from the unmodded console.')
if not success then
    ui.echo('SD switch failed:\n' .. result .. "\nExiting script.")
    return
end
while not fs.exists('0:/Nintendo 3DS') do
    ui.show_png('9:/mset9-gm9/error.png')
    ui.echo("Error 01: Couldn't find the Nintendo 3DS folder.\nOn the next screen, eject the SD card and\ninsert it into the unmodded console.\nTurn it on and off again, then insert it\ninto this console.")
    local success, result = pcall(fs.sd_switch, 'Waiting for SD to be reinserted...')
    if not success then
        ui.echo('SD switch failed:\n' .. result .. "\nExiting script.")
        return
    end
end
ui.show_png('9:/mset9-gm9/info.png')
ui.echo('On the following screen, type in the combo.\n\nYou can safely ignore the warning\nthat says "!THIS IS NOT RECOMMENDED!"')
while not fs.allow('0:/Nintendo 3DS') do
    ui.show_png('9:/mset9-gm9/error.png')
    ui.echo('You did not provide access to the\nNintendo 3DS folder.\n\nPlease try again.')
    ui.show_png('9:/mset9-gm9/info.png')
    ui.echo('On the following screen, type in the combo.\n\nYou can safely ignore the warning\nthat says "!THIS IS NOT RECOMMENDED!"')
end