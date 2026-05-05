-- Đăng ký sự kiện chạy game
ScriptSupportEvent:registerEvent([=[Game.Run]=], function()
    local _, _, allPlayers = World:getAllPlayers(-1)
    for i = 1, #allPlayers do
        local playerid = allPlayers[i]
        Compass:init(playerid)
        Compass:scanPlayerInAnArea(playerid)
        Compass:rotateCompassPlate(playerid)
        Compass:displayNearPlayer(playerid)
        Compass:displayFarPlayer(playerid)
    end
end)

ScriptSupportEvent:registerEvent([=[Game.AnyPlayer.LeaveGame]=], function(event)
    local playerid = event.eventobjid
    PrivatePlayerList[playerid] = nil
end)