local addonName = "QuestCompletionSound"
local version = "1.0"

local QuestCompletionSoundDB = {
    sound = "Interface\\AddOns\\QuestCompletionSound\\sounds\\questcompleted.ogg"
}

local previousObjectives = {}
local previousCompleted = {}
local isInitialScan = true

local function ScanQuests()
    local newStates = {}
    local newCompleted = {}
    
    -- Debug: Sprawdź, czy funkcja się wywołuje
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF" .. addonName .. "|r: Scanning quests... Initial scan: " .. (isInitialScan and "Yes" or "No"))
    
    for questIndex = 1, GetNumQuestLogEntries() do
        local title, level, tag, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(questIndex)
        
        if not isHeader then
            local id = questID or questIndex
            
            -- Debug: Informacje o queście
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF" .. addonName .. "|r: Quest [" .. (title or "Unknown") .. "] ID: " .. id .. ", isComplete: " .. (isComplete and "Yes" or "No"))
            
            -- Sprawdź ukończenie całego questa
            if isComplete and not previousCompleted[id] and not isInitialScan then
                PlaySoundFile(QuestCompletionSoundDB.sound, "Master")
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Quest completed! (" .. (title or "Unknown") .. ")")
                previousCompleted[id] = true
            elseif isComplete then
                previousCompleted[id] = true
            end
            
            -- Sprawdź cele dla nieukończonych questów
            if not isComplete then
                newStates[id] = newStates[id] or {}
                
                local numObjectives = GetNumQuestLeaderBoards(questIndex)
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FFFF" .. addonName .. "|r: Quest [" .. (title or "Unknown") .. "] has " .. numObjectives .. " objectives")
                
                for objectiveIndex = 1, numObjectives do
                    local text, objectiveType, finished = GetQuestLogLeaderBoard(objectiveIndex, questIndex)
                    local key = id .. "-" .. objectiveIndex
                    newStates[key] = finished and true or false
                    
                    -- Debug: Informacje o celu
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

local frame = CreateFrame("Frame", addonName .. "Frame")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "QUEST_LOG_UPDATE" then
        ScanQuests()
    end
end)

local loadedFrame = CreateFrame("Frame")
loadedFrame:RegisterEvent("VARIABLES_LOADED")
loadedFrame:SetScript("OnEvent", function()
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Loaded (" .. version .. ")")
    isInitialScan = true
    ScanQuests()
end)

SLASH_QCS1 = "/qcs"
SlashCmdList["QCS"] = function(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Loaded (" .. version .. ")")
    -- Test dźwięku
    if msg == "test" then
        PlaySoundFile(QuestCompletionSoundDB.sound, "Master")
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Test sound played")
    end
end