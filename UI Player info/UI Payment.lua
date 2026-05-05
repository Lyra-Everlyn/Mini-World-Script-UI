-- 1. CONFIGURATION & LOOKUP TABLES
local UIID = "7483275955022154623"
local MainElement = UIID .. "_69"
local CloseThisUI = UIID .. "_78"

local TabList = { UIID.."_75", UIID.."_76", UIID.."_77" }
local PackageList = { UIID.."_72", UIID.."_73", UIID.."_70" }
local MoneyTypeList = { UIID.."_107", UIID.."_108", UIID.."_109" }
local ReciveItemCountList = { UIID.."_103", UIID.."_104", UIID.."_105" }
local PriceList = { UIID.."_111", UIID.."_112", UIID.."_113" }

local OpenBtnToTabIndex = {
    [UIID.."_63"] = 1,
    [UIID.."_64"] = 2,
    [UIID.."_68"] = 3
}
local IconMoneyList = {
    "7483275955022154623_86", "7483275955022154623_101", "7483275955022154623_119",
    "7483275955022154623_120", "7483275955022154623_87", "7483275955022154623_88",
    "7483275955022154623_102", "7483275955022154623_121", "7483275955022154623_122",
    "7483275955022154623_89", "7483275955022154623_90", "7483275955022154623_91",
    "7483275955022154623_92","7483275955022154623_100", "7483275955022154623_123"

} -- Icon hiển thị trên gói

local MoneyByMapCard = { UIID.."_61", UIID.."_62", UIID.."_67" }
local KeyStorageMoneyByMap = { "GrassBlocks", "GoldenBlocks", "DiamondBlocks" }

local ConfigData = {
    { -- Index 1
        tabID = TabList[1],
        prices = {"20", "40", "90"},
        counts = {"1000", "2000", "5000"},
        items = {4097, 4098, 4099},
        name = "Khối Nguyên Sinh",
        currencyName = "Đậu mini",
        currencyIcon = [[8_1062292351_1777621812]],
        mapIcon = [[8_1062292351_1776178934]],
        storage = KeyStorageMoneyByMap[1]
    },
    { -- Index 2
        tabID = TabList[2],
        prices = {"30", "60", "130"},
        counts = {"100", "200", "500"},
        items = {4100, 4101, 4102},
        name = "Khối Hổ Phách",
        currencyName = "Điểm mini",
        currencyIcon = [[8_1062292351_1777619814]],
        mapIcon = [[8_1062292351_1776178946]],
        storage = KeyStorageMoneyByMap[2]
    },
    { -- Index 3
        tabID = TabList[3],
        prices = {"50", "100", "250"},
        counts = {"10", "20", "50"},
        items = {4103, 4105, 4106},
        name = "Khối Lam Ngọc",
        currencyName = "Xu mini",
        currencyIcon = [[8_1062292351_1777619810]],
        mapIcon = [[8_1062292351_1776178950]],
        storage = KeyStorageMoneyByMap[3]
    }
}

-- BẢNG TRA CỨU NHANH
-- Giúp tìm thông tin gói chỉ bằng ItemID trong 0.001ms
local ItemLookup = {}
for tabIdx, data in ipairs(ConfigData) do
    for pkgIdx, itemID in ipairs(data.items) do
        ItemLookup[itemID] = {
            count = tonumber(data.counts[pkgIdx]),
            price = tonumber(data.prices[pkgIdx]),
            storage = data.storage,
            name = data.name,
            currency = data.currencyName
        }
    end
end

local PlayerCurrentTabIdx = {}


-- 2. CORE FUNCTIONS
local function updateUIByTab(playerid, tabIdx)
    local data = ConfigData[tabIdx]
    if not data then return end
    PlayerCurrentTabIdx[playerid] = tabIdx

    for i = 1, 3 do
        Customui:setTexture(playerid, UIID, MoneyTypeList[i], data.currencyIcon)
        Customui:setText(playerid, UIID, PriceList[i], data.prices[i])
        Customui:setText(playerid, UIID, ReciveItemCountList[i], data.counts[i])
    end

    for _, iconElement in ipairs(IconMoneyList) do
        Customui:setTexture(playerid, UIID, iconElement, data.mapIcon)
    end
end

local function updateDisplayMoneyCard(playerid, specificIdx)
    local range = specificIdx and {specificIdx} or {1, 2, 3}
    for _, i in ipairs(range) do
        local _, value = VarLib2:getPlayerVarByName(playerid, VARTYPE.NUMBER, KeyStorageMoneyByMap[i])
        Customui:setText(playerid, UIID, MoneyByMapCard[i], value or 0)
    end
end

-- ==========================================
-- 3. EVENTS
-- ==========================================

local function helperEvent(event)
    local playerid, elementid = event.eventobjid, event.uielement

    if elementid == CloseThisUI then
        Customui:hideElement(playerid, UIID, MainElement)
        return
    end

    -- Check nút mở nạp
    if OpenBtnToTabIndex[elementid] then
        updateUIByTab(playerid, OpenBtnToTabIndex[elementid])
        Customui:showElement(playerid, UIID, MainElement)
        return
    end

    -- Check chuyển Tab
    for idx, tabID in ipairs(TabList) do
        if elementid == tabID then
            updateUIByTab(playerid, idx)
            return
        end
    end

    -- Check click vào gói
    for i, pkgID in ipairs(PackageList) do
        if elementid == pkgID then
            local currentIdx = PlayerCurrentTabIdx[playerid] or 1
            local itemid = ConfigData[currentIdx].items[i]
            local _, itemName = Item:getItemName(itemid)
            Player:openDevGoodsBuyDialog(playerid, itemid, "Xác nhận mua " .. itemName .. "?")
            return
        end
    end
end

local function onPurchaseSuccess(event)
    local info = ItemLookup[event.itemid]
    if not info then return end

    local playerid = event.eventobjid
    local _, value = VarLib2:getPlayerVarByName(playerid, VARTYPE.NUMBER, info.storage)
    value = (value or 0) + info.count

    VarLib2:setPlayerVarByName(playerid, VARTYPE.NUMBER, info.storage, value)
    updateDisplayMoneyCard(playerid)

    Chat:sendSystemMsg(string.format("#G[Nạp gói] Thành công! +%d %s", info.count, info.name), playerid)
    Chat:sendSystemMsg(string.format("#Y[Thanh toán] -%d %s", info.price, info.currency), playerid)
end


ScriptSupportEvent:registerEvent("Game.AnyPlayer.EnterGame", function(e)
    updateUIByTab(e.eventobjid, 1)
    updateDisplayMoneyCard(e.eventobjid)
end)
ScriptSupportEvent:registerEvent("UI.Button.Click", helperEvent)
ScriptSupportEvent:registerEvent("Developer.BuyItem", onPurchaseSuccess)