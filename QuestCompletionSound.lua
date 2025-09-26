local addonName = "QuestCompletionSound"

-- Domyślna baza danych (jeśli nie istnieje) if not QuestCompletionSoundDB then QuestCompletionSoundDB = {} end

-- Domyślny dźwięk (Twój plik questcompleted.ogg) if not QuestCompletionSoundDB.sound then QuestCompletionSoundDB.sound = "Interface\AddOns\QuestCompletionSound\sounds\questcompleted.ogg" end

-- Poprzednie stany celów (do porównania) local previousObjectives = {}

-- Funkcja skanowania questów i wykrywania nowych ukończeń local function ScanQuests() local newStates = {}

for questIndex = 1, GetNumQuestLogEntries() do
    local title, level, tag, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(questIndex)
    
    -- Pomijamy headers i ukończone questy
    if not isHeader and not isComplete then
        newStates[questID] = newStates[questID] or {}
        
        for objectiveIndex = 1, GetNumQuestLeaderBoards(questIndex) do
            local text, objectiveType, finished = GetQuestLogLeaderBoard(objectiveIndex, questIndex)
            
            local key = questID .. "-" .. objectiveIndex
            newStates[key] = (finished == 1) and true or false
            
            -- Sprawdź, czy to nowe ukończenie (było false, teraz true)
            if newStates[key] and not previousObjectives[key] then
                -- Odtwórz dźwięk!
                PlaySoundFile(QuestCompletionSoundDB.sound)
                -- Opcjonalnie: komunikat w chacie (możesz wyłączyć)
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Cel ukończony! (" .. (text or "Unknown") .. ")")
            end
        end
    end
end

-- Aktualizuj poprzednie stany
previousObjectives = newStates

end

-- Frame do eventów local frame = CreateFrame("Frame", addonName .. "Frame") frame:RegisterEvent("QUEST_LOG_UPDATE") frame:SetScript("OnEvent", function(self, event, ...) if event == "QUEST_LOG_UPDATE" then ScanQuests() end end)

-- Inicjalne skanowanie ScanQuests()

-- Slash komendy SLASH_QCS1 = "/qcs" SlashCmdList["QCS"] = function(msg) local cmd, arg = strsplit(" ", msg:lower(), 2)

if cmd == "sound" then
    if arg and arg ~= "" then
        QuestCompletionSoundDB.sound = arg
        print(addonName .. ": Dźwięk ustawiony na |cFFFFFF00" .. arg .. "|r")
        print(" |cFF888888Tip: Użyj podwójnych backslashy w ścieżce, np. Interface\\\\AddOns\\\\...|r")
    else
        print(addonName .. ": Bieżący dźwięk: |cFFFFFF00" .. QuestCompletionSoundDB.sound .. "|r")
        print("Użycie: |cFF00FF00/qcs sound <ścieżka>|r (np. \"Interface\\\\AddOns\\\\QuestCompletionSound\\\\sounds\\\\ding.ogg\")")
    end
else
    print(addonName .. ": Odtwarza dźwięk po ukończeniu celu questa.")
    print("Komendy: |cFF00FF00/qcs sound [ścieżka]|r - Ustaw/pokaż customowy dźwięk")
end

end

-- Ładuj po VARIABLES_LOADED (dla SavedVariables) local loadedFrame = CreateFrame("Frame") loadedFrame:RegisterEvent("VARIABLES_LOADED") loadedFrame:SetScript("OnEvent", function() -- Ponowne skanowanie po załadowaniu ScanQuests() end)