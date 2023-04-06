local bootCode = [[
    local result, reason = ""

    do
        local handle, chunk = component.proxy(component.list("internet")() or error("Internet card is required to launch")).request("https://raw.githubusercontent.com/dxAugust/MoonOS/master/Installer/main.lua")

        while true do
            chunk = handle.read(math.huge)
            
            if chunk then
                result = result .. chunk
            else
                break
            end
        end

        handle.close()
    end

    result, reason = load(result, "=installer")

    if result then
        result, reason = xpcall(result, debug.traceback)

        if not result then
            error(reason)
        end
    else
        error(reason)	
    end
]]

--- Be careful you will see a govnocoded installer

local components = require("component")
local event = require("event")
local gpu = components.gpu
local w, h = gpu.getResolution()

local languageList = { "Русский", "English" }
local selectedLang = 2

local currentPage = 0
local listOpened = false

local labelLang = "Select your language down below"
local labelSure = "Are you sure you want to install LunaOS?"
local installButtonLabel = "Install"
local cancelButtonLabel = "Cancel"

local function installButtonPressed()
    currentPage = 1
    print('Install button pressed')
end

local function cancelButtonPressed()
    
end

local function drawLangList()
    gpu.setForeground(0x858585)
    gpu.setBackground(0xBABABA)

    for i = 0, #languageList do
        gpu.fill(w/2 - #labelLang/8 + ((#labelLang/8)/2)*2, h/2 + 3 + ((i + 1) * 2), #labelLang - 8, 2, " ")

        if languageList[i] ~= nil then
            gpu.set(w/2 - #labelLang/8 + ((#labelLang/8)/2)*2 + 2, h/2 + 3 + ((i * 2) + 2) - 1, languageList[i])
        end
    end
end

local function onTouchHandler(x, y)
    if currentPage == 0 then
        if x >= w/2 - #labelLang/8 + ((#labelLang/8)/2)*2 + 2 and x <= w/2 - #labelLang/8 + ((#labelLang/8)/2)*2 + 2 + (#labelLang - 8) then
            if y >= h/2 + 2 and y <= h/2 + 5 then
                listOpened = not listOpened
            end
        end

        if listOpened == true then
            if x >= w/2 - #labelLang/8 + ((#labelLang/8)/2)*2 and x <= w/2 - #labelLang/8 + ((#labelLang/8)/2)*2 + (#labelLang - 8) then
                if y >= 30 and y <= 30 + (#languageList * 3) then
                    selectedLocale = ((y - 30)/3) + 1
                end
            end
        end
    end

    if currentPage == 1 then
        if x >= 75 and x <= 90 then
            if y >= 30 and y <= 33 then
                installButtonPressed()
            end
        end

        if x >= 100 and x <= 115 then 
            if y >= 30 and y <= 33 then
                cancelButtonPressed()
            end
        end
    end
end

local function fetchUserLocale(selectedLocale)

end

local function drawInstallerWindow()
    gpu.setForeground(0x858585)
    gpu.setBackground(0x1E1E1E)
    gpu.fill(1, 1, w, h, " ")

    gpu.setBackground(0xD5D5D5)
    gpu.fill(w/4, h/4, w/2, h/2, " ")

    gpu.setBackground(0xE0E0E0)
    gpu.fill((w/2)-20, (h/4), (w/2)-10, (h/2), " ")

    gpu.setBackground(0xD5D5D5)

    local stageEula = "> Hueula"
    gpu.set(w/4 + #stageEula/2, h/4 + 6, stageEula)

    local stageEEProm = "- EEPROM"
    gpu.set(w/4 + #stageEEProm/2, h/4 + 8, stageEEProm)

    local stageOS = "- OS Install"
    gpu.set(w/4 + #stageOS/3, h/4 + 10, stageOS)

    if currentPage == 0 then
        gpu.setBackground(0xE0E0E0)
        gpu.set(w/2 - #labelLang/8, h/2, labelLang)

        gpu.setBackground(0xD5D5D5)
        gpu.fill(w/2 - #labelLang/8 + ((#labelLang/8)/2)*2, h/2 + 2, #labelLang - 8, 3, " ")
        gpu.set(w/2 - #labelLang/8 + ((#labelLang/8)/2)*2 + 2, h/2 + 3, languageList[selectedLang])

        if listOpened == true then
            drawLangList()
        end
    end

    if currentPage == 1 then
        gpu.set(w/2 - #labelSure/8, h/2, labelSure)

        gpu.setForeground(0xFFFFFF)
        gpu.setBackground(0x2AD400)
        gpu.fill(75, 30, 15, 3, " ")
        gpu.set(75 + #installButtonLabel/2, 31, installButtonLabel)

        gpu.setForeground(0xFFFFFF)
        gpu.setBackground(0xDE0D0D)
        gpu.fill(100, 30, 15, 3, " ")
        gpu.set(100 + #cancelButtonLabel/2, 31, cancelButtonLabel)
    end
end

drawInstallerWindow()

---components.eeprom.set(bootCode)
---components.eeprom.setLabel("Snus EFI")

while true do
    local id, _, x, y = event.pullMultiple("touch", "interrupted")

    drawInstallerWindow()

    if id == "touch" then
        onTouchHandler(x, y)
    end
end