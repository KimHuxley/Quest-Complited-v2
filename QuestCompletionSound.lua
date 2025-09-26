local addonName = "QuestCompletionSound"


if not QuestCompletionSoundDB then
    QuestCompletionSoundDB = {}
end


if not QuestCompletionSoundDB.sound then
    QuestCompletionSoundDB.sound = "Interface\\AddOns\\QuestCompletionSound\\sounds\\questcompleted.ogg"
end


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


SLASH_QCS1 = "/qcs"
SlashCmdList["QCS"] = function(msg)

    local cmd, arg = "", ""
    if msg then
        local spacePos = string.find(msg, " ")
        if spacePos then
            cmd = string.sub(msg, 1, spacePos - 1)
            arg = string.sub(msg, spacePos + 1)
        else
            cmd = msg
        end
    end
    cmd = string.lower(cmd)
    
    if cmd == "sound" then
        if arg and arg ~= "" then
            QuestCompletionSoundDB.sound = arg
            print(addonName .. ": Sound set to |cFFFFFF00" .. arg .. "|r")
            print(" |cFF888888Tip: Use double backslashes in the path, e.g., Interface\\\\AddOns\\\\...|r")
        else
            print(addonName .. ": Current sound: |cFFFFFF00" .. QuestCompletionSoundDB.sound .. "|r")
            print("Usage: |cFF00FF00/qcs sound <path>|r (e.g., \"Interface\\\\AddOns\\\\QuestCompletionSound\\sounds\\ding.ogg\")")
        end
    else
        print(addonName .. ": Plays a sound upon completing a quest objective.")
        print("Commands: |cFF00FF00/qcs sound [path]|r - Set or show custom sound")
    end
end


local loadedFrame = CreateFrame("Frame")
loadedFrame:RegisterEvent("VARIABLES_LOADED")
loadedFrame:SetScript("OnEvent", function()

    ScanQuests()
end)