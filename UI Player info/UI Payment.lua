local TabList = {
    "7483275955022154623_75", -- Nạp mua khối nguyên sinh
    "7483275955022154623_76", -- Nạp mua khối hổ phách
    "7483275955022154623_77", -- Nạp mua khối lam ngọc
}

local PackageList = {
    "7483275955022154623_72", -- Gói 1
    "7483275955022154623_73", -- Gói 2
    "7483275955022154623_70", -- Gói 3
}

local MoneyTypeList = {
    "7483275955022154623_107", -- Icon hiển thị loại tiền gói 1
    "7483275955022154623_108", -- Icon hiển thị loại tiền gói 2
    "7483275955022154623_109",  -- Icon hiển thị loại tiền gói 3
}
local ReciveItemCountList = {
    "7483275955022154623_103", -- Số lượng vật phẩm nhận được gói 1
    "7483275955022154623_104", -- Số lượng vật phẩm nhận được gói 2
    "7483275955022154623_105", -- Số lượng vật phẩm nhận được gói 3
}
local PriceList = {
    "7483275955022154623_111", -- Giá gói 1
    "7483275955022154623_112", -- Giá gói 2
    "7483275955022154623_113",  -- Giá gói 3
}

local IconMoneyList = {
    "7483275955022154623_86", "7483275955022154623_101", "7483275955022154623_119", 
    "7483275955022154623_120", "7483275955022154623_87", "7483275955022154623_88", 
    "7483275955022154623_102", "7483275955022154623_121", "7483275955022154623_122", 
    "7483275955022154623_89", "7483275955022154623_90", "7483275955022154623_91", 
    "7483275955022154623_92","7483275955022154623_100", "7483275955022154623_123"
} -- Icon hiển thị trên gói

local IconMoneyByGame = {
    [[8_1062292351_1777619810]], -- Xu mini
    [[8_1062292351_1777619814]], -- Điểm mini
    [[8_1062292351_1777621812]], -- Đậu mini
}

local IconMoneyByMap = {
    [[8_1062292351_1776178934]], -- Khối nguyên sinh
    [[8_1062292351_1776178946]], -- Khối hổ phách
    [[8_1062292351_1776178950]], -- Khối lam ngọc
}

local CloseThisUI = "7483275955022154623_78"
local MainElement = "7483275955022154623_69"
local UIID = "7483275955022154623"

local PlayerCurrentTab = {} -- Biến riêng lưu tab hiện tại

local ConfigData = {
    [TabList[1]] = { -- Tab Khối Nguyên Sinh
        prices = {"20", "40", "90"},
        counts = {"1000", "2000", "5000"},
        moneyByMapInShop = {1, 2, 3},      -- Itemid thực tế trong map
        currencyIcon = IconMoneyByGame[3], -- Đậu mini (Xanh lá)
        mapItemIcon = IconMoneyByMap[1]    -- Đường dẫn ảnh Khối Nguyên Sinh
    },
    [TabList[2]] = { -- Tab Khối Hổ Phách
        prices = {"30", "60", "120"},
        counts = {"100", "200", "500"},
        moneyByMapInShop = {4, 5, 6},
        currencyIcon = IconMoneyByGame[2], -- Điểm mini (Xanh dương)
        mapItemIcon = IconMoneyByMap[2]    -- Đường dẫn ảnh Khối Hổ Phách
    },
    [TabList[3]] = { -- Tab Khối Lam Ngọc
        prices = {"50", "100", "250"},
        counts = {"10", "20", "50"},
        moneyByMapInShop = {7, 8, 9},
        currencyIcon = IconMoneyByGame[1], -- Xu mini (Vàng)
        mapItemIcon = IconMoneyByMap[3]    -- Đường dẫn ảnh Khối Lam Ngọc
    }
}

-- Hàm cập nhật giao diện khi chuyển Tab
local function updateUIByTab(playerid, tabElementID)
    local data = ConfigData[tabElementID]
    if not data then return end
    PlayerCurrentTab[playerid] = tabElementID

    for i = 1, 3 do
        Customui:setTexture(playerid, UIID, MoneyTypeList[i], data.currencyIcon)
        Customui:setText(playerid, UIID, PriceList[i], data.prices[i])
        Customui:setText(playerid, UIID, ReciveItemCountList[i], data.counts[i])

        for j = 1, #IconMoneyList do
            Customui:setTexture(playerid, UIID, IconMoneyList[j], data.mapItemIcon)
        end
    end
end

-- Xử lý sự kiện Click
local function OnButtonClick(event)
    local playerid = event.eventobjid
    local elementid = event.uielement
    -- Đóng giao diện
    if elementid == CloseThisUI then
        Customui:hideElement(playerid, UIID, MainElement)
        return
    end

    -- Chuyển Tab
    for _, tabID in ipairs(TabList) do
        if elementid == tabID then
            updateUIByTab(playerid, elementid)
            return
        end
    end

    -- Xử lý Mua Gói
    for i, pkgID in ipairs(PackageList) do
        if elementid == pkgID then
            local currentTab = PlayerCurrentTab[playerid] or TabList[1]
            local itemid = ConfigData[currentTab].moneyByMapInShop[i]

            -- Gọi cửa sổ thanh toán của Mini World (Dùng cho Developer Item)
            return
        end
    end
end

-- Xử lý khi thanh toán thành công
local function transferMoneyByMapToPlayer(event)
    local playerid = event.eventobjid
    local itemid = event.itemid -- ID vật phẩm Dev vừa mua

    -- Duyệt qua ConfigData để tìm xem itemid này tương ứng với gói nào
    for tabID, data in pairs(ConfigData) do
        for i, configItemID in ipairs(data.moneyByMapInShop) do
            if configItemID == itemid then
                local count = tonumber(data.counts[i])
                local price = tonumber(data.prices[i])

                -- Chat:sendSystemMsg(playerid, "Bạn đã mua thành công và nhận được: " .. count)

                return
            end
        end
    end
end

-- Đăng ký sự kiện
ScriptSupportEvent:registerEvent([=[UI.Button.Click]=], OnButtonClick)
ScriptSupportEvent:registerEvent("Developer.BuyItem", transferMoneyByMapToPlayer)
ScriptSupportEvent:registerEvent("Game.AnyPlayer.EnterGame", function(event)
    updateUIByTab(event.eventobjid, TabList[1])
end)