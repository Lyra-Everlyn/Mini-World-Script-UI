--[[
    Hệ thống giao diện la bàn mini map
    Tác giả: Lyra Everlyn
    UID: 62292351
]]

local UIID = "7542378617730321279"
local CompassIMGSize = 160         -- Kích thước của hình ảnh la bàn
local PoiterPos = {x = 80, y = 80} -- Tọa độ trung tâm của la bàn (poiter chỉ người chơi ở trung tâm)
local CompassPlate = UIID .. "_7"

-- Chấm người trong trong đĩa la bàn
local PoiterNearObj = {
    UIID .. "_24", UIID .. "_25", UIID .. "_26",
    UIID .. "_27", UIID .. "_28", UIID .. "_29",
}

-- Chấm người chơi ở xa
local PoiterFarObj = {
    UIID .. "_13", UIID .. "_14", UIID .. "_16",
    UIID .. "_18", UIID .. "_20", UIID .. "_22",
}

local Compass = {}

-- Danh sách người chơi trong phòng
local PrivatePlayerList = {}

-- Khởi tạo dữ liệu cho người chơi
function Compass:init(playerid)
    if not PrivatePlayerList[playerid] then
        PrivatePlayerList[playerid] = {
            near = {},
            far = {},
        }
    end
end

-- Quét các người chơi trong khu vực
function Compass:scanPlayerInAnArea(playerid)
    local _, x, y, z = Player:getPosition(playerid)
    local _, _, allPlayers = World:getAllPlayers(-1)

    local newNearList = {}
    local newFarList = {}
    local maxPointers = 6

    for i = 1, #allPlayers do
        local otherPlayerId = allPlayers[i]

        if otherPlayerId ~= playerid then
            local _, xp, yp, zp = Player:getPosition(otherPlayerId)
            local distance = math.sqrt((x - xp)^2 + (y - yp)^2 + (z - zp)^2)

            if distance <= (CompassIMGSize / 2) - 1 and #newNearList < maxPointers then
                table.insert(newNearList, otherPlayerId)
            elseif distance > (CompassIMGSize / 2) - 1 and #newFarList < maxPointers then
                table.insert(newFarList, otherPlayerId)
            end
        end
    end

    PrivatePlayerList[playerid].near = newNearList
    PrivatePlayerList[playerid].far = newFarList
end

-- Lấy góc xoay của người chơi
function Compass:getRotationAngle(playerid)
    local _, x, y, z = Player:getPosition(playerid)
    local _, aimX, aimY, aimZ = Player:getAimPos(playerid)

    local dx = aimX - x
    local dz = aimZ - z

    local angleRad = math.atan2(dx, dz)
    local rotate = math.deg(angleRad)

    rotate = (rotate + 360) % 360

    return rotate
end

-- Xoay la bàn
function Compass:rotateCompassPlate(playerid)
    local playerRotate = Compass:getRotationAngle(playerid)
    Customui:rotateElement(playerid, UIID, CompassPlate, -playerRotate)
end

-- Hiển thị chấm người chơi gần
function Compass:displayNearPlayer(playerid)
    local _, x, y, z = Player:getPosition(playerid)
    local playerRotate = Compass:getRotationAngle(playerid)

    for i = 1, #PoiterNearObj do
        Customui:hideElement(playerid, UIID, PoiterNearObj[i])
    end

    for i = 1, #PrivatePlayerList[playerid].near do
        local otherPlayerId = PrivatePlayerList[playerid].near[i]
        local _, xp, yp, zp = Player:getPosition(otherPlayerId)

        local dx = xp - x
        local dz = zp - z

        -- Góc của đối tượng so với hướng Bắc
        local angleToObjRad = math.atan2(dx, dz)
        local angleToObjDeg = math.deg(angleToObjRad)
        angleToObjDeg = (angleToObjDeg + 360) % 360

        -- Góc tương đối của con trỏ so với hướng người chơi
        local relativeAngleDeg = (angleToObjDeg - playerRotate + 360) % 360
        local relativeAngleRad = math.rad(relativeAngleDeg)

        local distance = math.sqrt(dx^2 + dz^2)
        local distanceUI = math.min(distance, (CompassIMGSize / 2) - 1)

        -- Tính tọa độ của con trỏ trên la bàn
        local xPoiter = PoiterPos.x + distanceUI * math.sin(relativeAngleRad)
        local yPoiter = PoiterPos.y - distanceUI * math.cos(relativeAngleRad)

        Customui:showElement(playerid, UIID, PoiterNearObj[i])
        Customui:setPosition(playerid, UIID, PoiterNearObj[i], xPoiter, yPoiter - 0)
    end
end

-- Hiển thị chấm người chơi xa
function Compass:displayFarPlayer(playerid)
    local _, x, y, z = Player:getPosition(playerid)
    local playerRotate = Compass:getRotationAngle(playerid)

    for i = 1, #PoiterFarObj do
        Customui:hideElement(playerid, UIID, PoiterFarObj[i])
    end

    for i = 1, #PrivatePlayerList[playerid].far do
        local otherPlayerId = PrivatePlayerList[playerid].far[i]
        local _, xp, yp, zp = Player:getPosition(otherPlayerId)

        local dx = xp - x
        local dz = zp - z

        local angleToObjRad = math.atan2(dx, dz)
        local angleToObjDeg = math.deg(angleToObjRad)
        angleToObjDeg = (angleToObjDeg + 360) % 360

        local relativeAngleDeg = (angleToObjDeg - playerRotate + 360) % 360

        Customui:showElement(playerid, UIID, PoiterFarObj[i])
        Customui:rotateElement(playerid, UIID, PoiterFarObj[i], relativeAngleDeg + 180)
    end
end