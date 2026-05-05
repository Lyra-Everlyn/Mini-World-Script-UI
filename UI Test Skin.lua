--[[
    Hệ thống giao diện Test Skin Mini World
    Tác giả: Lyra Everlyn
    UID: 62292351
]]--

-- ID Giao diện
local UIID = "7300448921037392767"

-- Thành phần hiển thị avatar skin(nút chọn skin)
local SKinElements = {
    "7300448921037392767_7", "7300448921037392767_8", "7300448921037392767_9",
    "7300448921037392767_10", "7300448921037392767_11", "7300448921037392767_26",
    "7300448921037392767_29", "7300448921037392767_32"
}

-- Khung, viền ảnh
local BackgroundElements = {
    "7300448921037392767_2", "7300448921037392767_3", "7300448921037392767_4",
    "7300448921037392767_5", "7300448921037392767_6", "7300448921037392767_25",
    "7300448921037392767_28", "7300448921037392767_31"
}

-- Chuyển thành phần chọn skin thành dạng [elementid] = true
local SelectSkinMap = {}
for i, elementid in ipairs(SKinElements) do SelectSkinMap[elementid] = i end

-- Các nút chuyển trang và hiển thị trang
local NextPage = UIID .. "_18"
local PreviousPage = UIID .. "_17"
local CurrentPage =  UIID .. "_19"

local ResetSkin = UIID .. "_22"
local ExitThisUI = UIID .. "_20"

-- Thông số riêng
local SkinLimit = 410
local SkinPerPage = 8
local TotalPage = math.ceil(SkinLimit / SkinPerPage)

-- Dữ liệu liên quan đến skin
local SkinModelList = {}
local SkinTexturelList = {}

-- Biến riêng trang hiển thị hiện tại
local PlayerCurrentPage = {}

-- Khởi tạo dữ liệu skin
local function initializingSkinData()
    -- Id skin không tồn tại
    local excludeIds = {
        [119]=true, [126]=true, [129]=true, [133]=true, [134]=true, [137]=true,
        [249]=true, [250]=true, [257]=true, [258]=true, [259]=true, [260]=true,
        [261]=true, [262]=true, [263]=true, [264]=true, [265]=true, [266]=true,
        [267]=true, [268]=true, [271]=true, [272]=true, [275]=true, [289]=true,
        [290]=true, [305]=true, [313]=true, [314]=true, [376]=true, [377]=true,
        [388]=true, [391]=true, [392]=true, [393]=true
    }

    for i = 1, SkinLimit do
        if not excludeIds[i] then
            SkinModelList[i] = "skin_" .. i
            SkinTexturelList[i] = tostring(6000000 + i)
        end
    end
end

-- Nạp dữ liệu sau khi game chạy
initializingSkinData()

-- Cập nhật trang hiển thị hiện tại
local function updateCurrentPage(playerid)
    local currentPageNumber = PlayerCurrentPage[playerid] or 1

    Customui:showElement(playerid, UIID, PreviousPage)
    Customui:showElement(playerid, UIID, NextPage)

    if currentPageNumber <= 1 then Customui:hideElement(playerid, UIID, PreviousPage) end
    if currentPageNumber >= TotalPage then Customui:hideElement(playerid, UIID, NextPage) end

    local startIndex = (currentPageNumber - 1) * SkinPerPage
    for i = 1, SkinPerPage do
        local skinIndex = startIndex + i
        local useSkinButton = SKinElements[i]
        local backgroundElement = BackgroundElements[i]

        if skinIndex <= SkinLimit then
            Customui:showElement(playerid, UIID, useSkinButton)
            Customui:showElement(playerid, UIID, backgroundElement)
            Customui:setTexture(playerid, UIID, useSkinButton, SkinTexturelList[skinIndex])
        else
            Customui:hideElement(playerid, UIID, useSkinButton)
            Customui:hideElement(playerid, UIID, backgroundElement)
        end
    end

    Customui:setText(playerid, UIID, CurrentPage, currentPageNumber .. "/" .. TotalPage)
end

-- Sự kiện bấm nút thay đổi trang
local function changeSkinPage(event)
    local playerid = event.eventobjid
    local elementid = event.uielement
    local currentPageNumber = PlayerCurrentPage[playerid] or 1

    if elementid == NextPage and currentPageNumber < TotalPage then
        PlayerCurrentPage[playerid] = currentPageNumber + 1
        updateCurrentPage(playerid)

    elseif elementid == PreviousPage and currentPageNumber > 1 then
        PlayerCurrentPage[playerid] = currentPageNumber - 1
        updateCurrentPage(playerid)
    end
end

-- Sự kiện bấm nút chọn skin
local function selectSKin(event)
    local selectIndex = SelectSkinMap[event.uielement]
    if not selectIndex then return end

    local currentPageNumber = PlayerCurrentPage[event.eventobjid] or 1
    local skinModelIndex = (currentPageNumber - 1) * SkinPerPage + selectIndex

    if SkinModelList[skinModelIndex] then
        Actor:changeCustomModel(event.eventobjid, SkinModelList[skinModelIndex])
    end
end

-- Sự kiện bấm nút trợ giúp
local function helperFunction(event)
    local playerid = event.eventobjid
    local elementid = event.uielement

    if elementid == ResetSkin then
        Actor:recoverinitialModel(playerid)

    elseif elementid == ExitThisUI then
        Player:changeViewMode(playerid, VIEWPORTTYPE.MAINVIEW, false)
        Player:hideUIView(playerid, UIID)
    end
end

-- Sự kiện mở UI
local function openThisUI(event)
    local playerid = event.eventobjid
    local uiid = event.CustomUI

    if uiid == UIID then
        Player:changeViewMode(playerid, VIEWPORTTYPE.FRONTVIEW, false)
        Player:rotateCamera(playerid, 90, 0)
    end
end

-- Sự kiện khởi tạo dữ liệu người chơi
local function initPlayerData(event)
    PlayerCurrentPage[event.eventobjid] = 1
    updateCurrentPage(event.eventobjid)
end

-- Sự kiện xóa dữ liệu người chơi
local function deletePlayerData(event)
    PlayerCurrentPage[event.eventobjid] = nil
end

ScriptSupportEvent:registerEvent("UI.Show", openThisUI)
ScriptSupportEvent:registerEvent("Game.AnyPlayer.EnterGame", initPlayerData)
ScriptSupportEvent:registerEvent("Game.AnyPlayer.LeaveGame", deletePlayerData)
ScriptSupportEvent:registerEvent("UI.Button.Click", changeSkinPage)
ScriptSupportEvent:registerEvent("UI.Button.Click", selectSKin)
ScriptSupportEvent:registerEvent("UI.Button.Click", helperFunction)