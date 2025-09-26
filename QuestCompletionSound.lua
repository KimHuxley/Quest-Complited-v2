local addonName = "QuestCompletionSound"
local version = "1.0"

local QuestCompletionSoundDB = {
    sound = "Interface\\AddOns\\QuestCompletionSound\\sounds\\questcompleted.ogg"
}

local previousObjectives = {}
local previousCompleted = {} -- Tabela do śledzenia ukończonych questów
local isInitialScan = true -- Flaga do ignorowania pierwszego skanu

local function ScanQuests()
    local newStates = {}
    local newCompleted = {}
    
    for questIndex = 1, GetNumQuestLogEntries() do
        local title, level, tag, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(questIndex)
        
        if not isHeader then
            local id = questID or questIndex
            
            -- Sprawdź, czy quest jest ukończony (ale nie oddany)
            if isComplete and not previousCompleted[id] and not isInitialScan then
                PlaySoundFile(QuestCompletionSoundDB.sound)
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Quest completed! (" .. (title or "Unknown") .. ")")
                previousCompleted[id] = true
            elseif isComplete then
                previousCompleted[id] = true -- Aktualizuj stan, ale bez dźwięku
            end
            
            -- Sprawdź cele dla nieukończonych questów
            if not isComplete then
                newStates[id] = newStates[id] or {}
                
                for objectiveIndex = 1, GetNumQuestLeaderBoards(questIndex) do
                    local text, objectiveType, finished = GetQuestLogLeaderBoard(objectiveIndex, questIndex)
                    
                    local key = id .. "-" .. objectiveIndex
                    newStates[key] = (finished == 1) and true or false
                    
                    if newStates[key] and not previousObjectives[key] and not isInitialScan then
                        PlaySoundFile(QuestCompletionSoundDB.sound)
                        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Objective completed! (" .. (text or "Unknown") .. ")")
                    end
                end
            end
        end
    end
    
    previousObjectives = newStates
    isInitialScan = false -- Po pierwszym skanie ustawiamy flagę na false
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
    isInitialScan = true -- Ustaw flagę na true przy ładowaniu
    ScanQuests()
end)

SLASH_QCS1 = "/qcs"
SlashCmdList["QCS"] = function(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Loaded (" .. version .. ")")
end