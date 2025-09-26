local addonName = "QuestCompletionSound"
local version = "1.3"

local QuestCompletionSoundDB = {
    sound = "Interface\\AddOns\\QuestCompletionSound\\sounds\\questcompleted.ogg"
}

local previousObjectives = {}
local previousCompleted = {}
local isInitialScan = true

local function PlaySoundSafe()
    if QuestCompletionSoundDB.sound then
        pcall(PlaySoundFile, QuestCompletionSoundDB.sound, "Master")
    end
end

local function ScanQuests()
    local newStates = {}
    local numEntries = GetNumQuestLogEntries() or 0

    for questIndex = 1, numEntries do
        local title, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(questIndex)
        if not isHeader then
            local id = tostring(questID or questIndex)
            local numObjectives = GetNumQuestLeaderBoards(questIndex) or 0
            local allFinished = true

            if numObjectives == 0 then
                allFinished = (isComplete == 1 or isComplete == -1)
            else
                for i = 1, numObjectives do
                    local text, _, finished = GetQuestLogLeaderBoard(i, questIndex)
                    local key = id .. "-" .. i
                    local finishedBool = finished and true or false
                    newStates[key] = finishedBool

                    if finishedBool and not previousObjectives[key] and not isInitialScan then
                        PlaySoundSafe()
                        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Objective completed! (" .. (text or "Unknown") .. ")")
                    end

                    if not finishedBool then
                        allFinished = false
                    end
                end
            end

            if allFinished and not previousCompleted[id] and not isInitialScan then
                PlaySoundSafe()
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Quest fully completed! (" .. (title or "Unknown") .. ")")
                previousCompleted[id] = true
            elseif (isComplete == 1 or isComplete == -1) then
                previousCompleted[id] = true
            end
        end
    end

    previousObjectives = newStates
    isInitialScan = false
end


local frame = CreateFrame("Frame", addonName .. "Frame")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterEvent("QUEST_WATCH_UPDATE")
frame:RegisterEvent("UNIT_QUEST_LOG_CHANGED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "UNIT_QUEST_LOG_CHANGED" then
        if arg1 == "player" then
            ScanQuests()
        end
    else
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
    if msg == "test" then
        PlaySoundSafe()
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Test sound played")
    end
end
