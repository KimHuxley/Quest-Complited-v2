1.  local addonName = "QuestCompletionSound"
2.  
3.  -- Domyślna baza danych (jeśli nie istnieje)
4.  if not QuestCompletionSoundDB then
5.      QuestCompletionSoundDB = {}
6.  end
7.  
8.  -- Domyślny dźwięk (Twój plik questcompleted.ogg)
9.  if not QuestCompletionSoundDB.sound then
10.     QuestCompletionSoundDB.sound = "Interface\\AddOns\\QuestCompletionSound\\sounds\\questcompleted.ogg"
11. end
12. 
13. -- Poprzednie stany celów (do porównania)
14. local previousObjectives = {}
15. 
16. -- Funkcja skanowania questów i wykrywania nowych ukończeń
17. local function ScanQuests()
18.     local newStates = {}
19.     
20.     for questIndex = 1, GetNumQuestLogEntries() do
21.         local title, level, tag, isHeader, isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(questIndex)
22.         
23.         -- Pomijamy headers i ukończone questy
24.         if not isHeader and not isComplete then
25.             newStates[questID] = newStates[questID] or {}
26.             
27.             for objectiveIndex = 1, GetNumQuestLeaderBoards(questIndex) do
28.                 local text, objectiveType, finished = GetQuestLogLeaderBoard(objectiveIndex, questIndex)
29.                 
30.                 local key = questID .. "-" .. objectiveIndex
31.                 newStates[key] = (finished == 1) and true or false
32.                 
33.                 -- Sprawdź, czy to nowe ukończenie (było false, teraz true)
34.                 if newStates[key] and not previousObjectives[key] then
35.                     -- Odtwórz dźwięk!
36.                     PlaySoundFile(QuestCompletionSoundDB.sound)
37.                     -- Opcjonalnie: komunikat w chacie (możesz wyłączyć)
38.                     DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00" .. addonName .. "|r: Cel ukończony! (" .. (text or "Unknown") .. ")")
39.                 end
40.             end
41.         end
42.     end
43.     
44.     -- Aktualizuj poprzednie stany
45.     previousObjectives = newStates
46. end
47. 
48. -- Frame do eventów
49. local frame = CreateFrame("Frame", addonName .. "Frame")
50. frame:RegisterEvent("QUEST_LOG_UPDATE")
51. frame:SetScript("OnEvent", function(self, event, ...)
52.     if event == "QUEST_LOG_UPDATE" then
53.         ScanQuests()
54.     end
55. end)
56. 
57. -- Inicjalne skanowanie
58. ScanQuests()
59. 
60. -- Slash komendy
61. SLASH_QCS1 = "/qcs"
62. SlashCmdList["QCS"] = function(msg)
63.     local cmd, arg = strsplit(" ", msg:lower(), 2)
64.     
65.     if cmd == "sound" then
66.         if arg and arg ~= "" then
67.             QuestCompletionSoundDB.sound = arg
68.             print(addonName .. ": Dźwięk ustawiony na |cFFFFFF00" .. arg .. "|r")
69.             print(" |cFF888888Tip: Użyj podwójnych backslashy w ścieżce, np. Interface\\\\AddOns\\\\...|r")
70.         else
71.             print(addonName .. ": Bieżący dźwięk: |cFFFFFF00" .. QuestCompletionSoundDB.sound .. "|r")
72.             print("Użycie: |cFF00FF00/qcs sound <ścieżka>|r (np. \"Interface\\\\AddOns\\\\QuestCompletionSound\\\\sounds\\\\ding.ogg\")")
73.         end
74.     else
75.         print(addonName .. ": Odtwarza dźwięk po ukończeniu celu questa.")
76.         print("Komendy: |cFF00FF00/qcs sound [ścieżka]|r - Ustaw/pokaż customowy dźwięk")
77.     end
78. end
79. 
80. -- Ładuj po VARIABLES_LOADED (dla SavedVariables)
81. local loadedFrame = CreateFrame("Frame")
82. loadedFrame:RegisterEvent("VARIABLES_LOADED")
83. loadedFrame:SetScript("OnEvent", function()
84.     -- Ponowne skanowanie po załadowaniu
85.     ScanQuests()
86. end)