local addonName = "QuestCompletionSound"
local version = "1.1"

-- Baza ustawień
local QuestCompletionSoundDB = {
    sound = "Interface\\AddOns\\QuestCompletionSound\\sounds\\questcompleted.ogg"
}

-- Zapamiętane stany
local previousObjectives = {}
local previousCompleted = {}
local isInitialScan = true

-- Funkcja skanująca questy i ich cele
local function ScanQuests()
    local newStates = {}

    -- Debug
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF" .. addonName .. "|r: Scanning quests... Initial scan: " .. (isInitialScan and "Yes" or "No"))

    for questIndex = 1, GetNumQuestLogEntries() do
        local title, level, tag, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(questIndex)

        if not isHeader then
            local id = questID or questIndex

            -- Debug: stan questa
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF" .. addonName .. "|r: Quest [" .. (title or "Unknown") .. "] ID: " .. id .. ", isComplete: " .. tostring(isComplete))

            -- Sprawdź ukończenie całego questa
            if (isComplete == 1 or isComplete == -1) and not previousCompleted[id] and not isInitialScan then
                PlaySoundFile(QuestCompletionSoundDB.sound, "Master")
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Quest completed! (" .. (title or "Unknown") .. ")")
                previousCompleted[id] = true
            elseif (isComplete == 1 or isComplete == -1) then
                previousCompleted[id] = true
            end

            -- Sprawdź cele questa
            if not (isComplete == 1 or isComplete == -1) then
                local numObjectives = GetNumQuestLeaderBoards(questIndex)
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF" .. addonName .. "|r: Quest [" .. (title or "Unknown") .. "] has " .. numObjectives .. " objectives")

                for objectiveIndex = 1, numObjectives do
                    local text, objectiveType, finished = GetQuestLogLeaderBoard(objectiveIndex, questIndex)
                    local key = id .. "-" .. objectiveIndex
                    newStates[key] = finished and true or false

                    -- Debug: cel questa
                    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF" .. addonName .. "|r: Objective [" .. (text or "Unknown") .. "] Finished: " .. (finished and "Yes" or "No"))

                    if newStates[key] and not previousObjectives[key] and not isInitialScan then
                        PlaySoundFile(QuestCompletionSoundDB.sound, "Master")
                        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Objective completed! (" .. (text or "Unknown") .. ")")
                    end
                end
            end
        end
    end

    previousObjectives = newStates
    isInitialScan = false
end

-- Główna ramka eventowa
local frame = CreateFrame("Frame", addonName .. "Frame")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterEvent("QUEST_WATCH_UPDATE") -- Dodane: wykrywanie pełnego ukończenia questa
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "QUEST_LOG_UPDATE" then
        ScanQuests()
    elseif event == "QUEST_WATCH_UPDATE" then
        local questID = arg1
        local title = C_QuestLog and C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(questID) or "Unknown"
        PlaySoundFile(QuestCompletionSoundDB.sound, "Master")
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Quest fully completed! (" .. title .. ")")
    end
end)

-- Event ładowania
local loadedFrame = CreateFrame("Frame")
loadedFrame:RegisterEvent("VARIABLES_LOADED")
loadedFrame:SetScript("OnEvent", function()
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Loaded (" .. version .. ")")
    isInitialScan = true
    ScanQuests()
end)

-- Slash command
SLASH_QCS1 = "/qcs"
SlashCmdList["QCS"] = function(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Loaded (" .. version .. ")")
    if msg == "test" then
        PlaySoundFile(QuestCompletionSoundDB.sound, "Master")
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Test sound played")
    end
end
