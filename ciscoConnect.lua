-- Hammerspoon module: Cisco Secure Client automation
-- Credentials are loaded **once** from ~/.hammerspoon/cisco_secrets.json
-- Example secrets file (JSON):
--   {
--     "username":   "your_username",
--     "passphrase": "your_password",
--     "totpSecret": "your_totp_secret",
--     "rdpFile":    "/Users/youruser/path/to/file.rdp"
--   }
-- If the file is missing or fields are absent, the script aborts early.

local M = {}

--------------------------------------------------------------------
-- CISCOSECRETS (cached at module‑load time) -----------------------------
--------------------------------------------------------------------
local function loadSecrets()
    local path = os.getenv("HOME") .. "/.hammerspoon/cisco_secrets.json"
    local secrets = hs.json.read(path)
    if not secrets then
        hs.alert.show("Unable to read secrets file: " .. path)
        return nil
    end
    if not (secrets.username and secrets.passphrase and secrets.totpSecret and secrets.rdpFile) then
        hs.alert.show("Secrets file missing required keys")
        return nil
    end
    return secrets
end

local CISCOSECRETS = loadSecrets() -- read once, cached in upvalue

--------------------------------------------------------------------
-- PUBLIC ENTRY -----------------------------------------------------
--------------------------------------------------------------------
function M.run()
    if not CISCOSECRETS then return end -- bail if secrets couldn't be loaded

    ------------------------------------------------------------------
    -- CONFIG ---------------------------------------------------------
    ------------------------------------------------------------------
    local appName     = "Cisco Secure Client"         -- bundle name
    local username    = CISCOSECRETS.username
    local passphrase  = CISCOSECRETS.passphrase
    local totpSecret  = CISCOSECRETS.totpSecret
    local rdpFile     = CISCOSECRETS.rdpFile

    ------------------------------------------------------------------
    -- UTILITIES ------------------------------------------------------
    ------------------------------------------------------------------
    local function waitForWindow(predicate, timeout)
        local start = os.time()
        while os.difftime(os.time(), start) < timeout do
            local app = hs.application.get(appName)
            if app then
                for _, w in ipairs(app:allWindows()) do
                    if predicate(w) then return w end
                end
            end
            hs.timer.usleep(200000) -- 0.2 s
        end
        return nil
    end

    local function waitForMainWindow(timeout)
        return waitForWindow(function(w) return w:isVisible() and w:isStandard() end, timeout)
    end

    local function waitForAuthWindow(mainWin, timeout)
        return waitForWindow(function(w)
            return w:isVisible() and w:id() ~= mainWin:id() -- any new visible window
        end, timeout)
    end

    local function findButtonByTitle(element, title)
        if not (element and element.attributeValue) then return nil end
        if element:attributeValue("AXRole") == "AXButton" and element:attributeValue("AXTitle") == title then
            return element
        end
        for _, child in ipairs(element:attributeValue("AXChildren") or {}) do
            local found = findButtonByTitle(child, title)
            if found then return found end
        end
        return nil
    end

    local function genTOTP()
        return hs.execute(string.format("oathtool -b --totp '%s'", totpSecret), true):gsub("%s+$", "")
    end

    ------------------------------------------------------------------
    -- MAIN -----------------------------------------------------------
    ------------------------------------------------------------------
    hs.application.launchOrFocus(appName)

    -- 1. Wait for the main window
    local mainWin = waitForMainWindow(15)
    if not mainWin then
        hs.alert.show("Could not find main window")
        return
    end

    -- 2. Click the "Connect" button on the main window
    local rootMain = hs.axuielement.windowElement(mainWin)
    local connectBtn = findButtonByTitle(rootMain, "Connect")
    if not connectBtn then
        hs.alert.show("\"Connect\" button not found")
        return
    end
    connectBtn:performAction("AXPress")

    -- 3. Wait for the authentication popup/window (web‑based)
    local authWin = waitForAuthWindow(mainWin, 10)
    if not authWin then
        hs.alert.show("Authentication window did not appear")
        return
    end
    authWin:focus()

    ------------------------------------------------------------------
    -- Sequential actions triggered *after* each Return press ---------
    ------------------------------------------------------------------
    local function stepRdpPassword()
        hs.eventtap.keyStrokes(passphrase)
        hs.eventtap.keyStroke({}, "return")
        hs.timer.doAfter(2.0, function() hs.eventtap.keyStroke({}, "return") end)
    end

    local function stepLaunchRdp()
        hs.execute(string.format("open '%s'", rdpFile), true)
        hs.timer.doAfter(2.5, stepRdpPassword)
    end

    local function stepFinalEnter()
        hs.eventtap.keyStroke({}, "return") -- final enter
        hs.timer.doAfter(4.0, stepLaunchRdp)
    end

    local function stepTotp()
        local code = genTOTP()
        if code == "" then
            hs.alert.show("TOTP generation failed")
        else
            hs.eventtap.keyStrokes(code)
        end
        hs.eventtap.keyStroke({}, "return")
        hs.timer.doAfter(2.5, stepFinalEnter)
    end

    local function stepPassphrase()
        hs.eventtap.keyStrokes(passphrase)
        hs.eventtap.keyStroke({}, "return")
        hs.timer.doAfter(3.0, stepTotp)
    end

    local function stepUsername()
        hs.eventtap.keyStrokes(username)
        hs.eventtap.keyStroke({}, "return")
        hs.timer.doAfter(3.0, stepPassphrase)
    end

    -- Kick off the chain 3 s after clicking Connect
    hs.timer.doAfter(3.0, stepUsername)
end

return M
