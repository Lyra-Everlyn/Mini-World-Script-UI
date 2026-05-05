local UIID = "7483275955022154623"
local AvatarID = UIID .. "_2"
local FrameID = UIID .. "_3"
local BoxNameID = UIID .. "_54"
local BoxIdID = UIID .. "_56"

function setPlayerAvatar(event)
    local playerid = event.eventobjid
    local _, avatar = Customui:getRoleIcon(playerid)
    local _, name = Player:getNickname(playerid)
    local randomValue = math.random(20201, 20292)

    Customui:setTexture(playerid, UIID, AvatarID, avatar)
    Customui:setTexture(playerid, UIID, FrameID, 2000000 + randomValue)
    Customui:setText(playerid, UIID, BoxNameID, name)
    Customui:setText(playerid, UIID, BoxIdID, playerid)

    if playerid == 1062292351 then
        Customui:setTexture(playerid, UIID, FrameID, 2020220)
    end
end

ScriptSupportEvent:registerEvent("Game.AnyPlayer.EnterGame", setPlayerAvatar)