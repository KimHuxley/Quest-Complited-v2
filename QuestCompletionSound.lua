local addonName = "QuestCompletionSound"
local version = "1.4"

local QuestCompletionSoundDB = {
    sound = "Interface\\AddOns\\QuestCompletionSound\\sounds\\questcompleted.ogg"
}

local previousCompleted = {}
local isInitialScan = true

local function PlaySoundSafe()
    if QuestCompletionSoundDB.sound then
        pcall(PlaySoundFile, QuestCompletionSoundDB.sound, "Master")
    end
end

local function ScanQuests()
    local numEntries = GetNumQuestLogEntries() or 0

    for questIndex = 1, numEntries do
        local title, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(questIndex)
        if not isHeader and questID then
            local id = tostring(questID)

            -- Quest ukończony (ale jeszcze nie oddany)
            if (isComplete == 1 or isComplete == -1) then
                if not previousCompleted[id] and not isInitialScan then
                    PlaySoundSafe()
                    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Quest completed! (" .. (title or "Unknown") .. ")")
                end
                previousCompleted[id] = true
            else
                previousCompleted[id] = false
            end
        end
    end

    isInitialScan = false
end

-- Eventy
local frame = CreateFrame("Frame", addonName .. "Frame")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "UNIT_QUEST_LOG_CHANGED" and arg1 ~= "player" then
        return
    end
    ScanQuests()
end)

-- Ładowanie
local loadedFrame = CreateFrame("Frame")
loadedFrame:RegisterEvent("VARIABLES_LOADED")
loadedFrame:SetScript("OnEvent", function()
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Loaded (" .. version .. ")")
    isInitialScan = true
    ScanQuests()
end)

-- Komenda testowa
SLASH_QCS1 = "/qcs"
SlashCmdList["QCS"] = function(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Loaded (" .. version .. ")")
    if msg == "test" then
        PlaySoundSafe()
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Test sound played")
    end
end
