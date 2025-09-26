local addonName = "QuestCompletionSound"

local QuestCompletionSoundDB = {
    sound = "Interface\\AddOns\\QuestCompletionSound\\sounds\\questcompleted.ogg"
}

local previousObjectives = {}

local function ScanQuests()
    local newStates = {}
    
    for questIndex = 1, GetNumQuestLogEntries() do
        local title, level, tag, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(questIndex)
        
        if not isHeader and not isComplete then
            local id = questID or questIndex
            newStates[id] = newStates[id] or {}
            
            for objectiveIndex = 1, GetNumQuestLeaderBoards(questIndex) do
                local text, objectiveType, finished = GetQuestLogLeaderBoard(objectiveIndex, questIndex)
                
                local key = id .. "-" .. objectiveIndex
                newStates[key] = (finished == 1) and true or false
                
                if newStates[key] and not previousObjectives[key] then
                    PlaySoundFile(QuestCompletionSoundDB.sound)
                    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Objective completed! (" .. (text or "Unknown") .. ")")
                end
            end
        end
    end
    
    previousObjectives = newStates
end

local frame = CreateFrame("Frame", addonName .. "Frame")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:SetScript("OnEvent", function(self, event, ...)
    if event == "QUEST_LOG_UPDATE" then
        ScanQuests()
    end
end)

ScanQuests()

local loadedFrame = CreateFrame("Frame")
loadedFrame:RegisterEvent("VARIABLES_LOADED")
loadedFrame:SetScript("OnEvent", function()
    ScanQuests()
end)