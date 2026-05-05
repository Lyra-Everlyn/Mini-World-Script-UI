local UIID = "7483275955022154623"
local HpBarAnimation1 = UIID .. "_6"
local HpBarAnimation2 = UIID .. "_5"
local HpBarText = UIID .. "_7"
local HpBarWidth, HpBarHeight = 400, 10

local function round(num, numDecimalPlaces)
    local multiplier = 10 ^ numDecimalPlaces
    return math.floor(num * multiplier + 0.5) / multiplier
end

local function setPlayerHpBar(event)
    local playerid = event.eventobjid
    local attrType = event.playerattr
    if attrType == 1 or attrType == 2 then
        local _, maxHp = Player:getAttr(playerid, 1)
        local _, currentHp = Player:getAttr(playerid, 2)
        local roundedCurrentHp = round(currentHp, 2)
        local percentHp = (currentHp / maxHp) * 100

        if percentHp >= 80 then -- HP rất cao
            Customui:setColor(playerid, UIID, HpBarAnimation1, "0x2ecc71")

        elseif percentHp >= 60 then -- HP cao
            Customui:setColor(playerid, UIID, HpBarAnimation1, "0x88ff00")

        elseif percentHp >= 45 then -- HP trung bình khá
            Customui:setColor(playerid, UIID, HpBarAnimation1, "0xf1ca1f")

        elseif percentHp >= 30 then -- HP trung bình
            Customui:setColor(playerid, UIID, HpBarAnimation1, "0xf39c12")

        elseif percentHp >= 15 then -- HP thấp
            Customui:setColor(playerid, UIID, HpBarAnimation1, "0xff6073")

        elseif percentHp >= 5 then-- HP nguy hiểm
            Customui:setColor(playerid, UIID, HpBarAnimation1, "0xff0022")

        else -- HP cực kỳ nguy hiểm
            Customui:setColor(playerid, UIID, HpBarAnimation1, "0x8b0000")

        end

        Customui:setText(playerid, UIID, HpBarText, roundedCurrentHp .. " / " .. maxHp)
        Customui:SmoothScaleTo(playerid, UIID, HpBarAnimation1, 0.5, roundedCurrentHp / maxHp * HpBarWidth, HpBarHeight)
        Trigger:wait(0.75)
        Customui:SmoothScaleTo(playerid, UIID, HpBarAnimation2, 0.5, roundedCurrentHp / maxHp * HpBarWidth, HpBarHeight)
    end
end

ScriptSupportEvent:registerEvent("Player.ChangeAttr", setPlayerHpBar)