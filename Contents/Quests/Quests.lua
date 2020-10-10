-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                      "SylingTracker.Quests"                           ""
-- ========================================================================= --
import                          "SLT"
-- ========================================================================= --
_Active                         = false
-- ========================================================================= --
-- Check if the player is on the Shadowlands environment
IsOnShadowlands               = Utils.IsOnShadowlands
RegisterContentType           = API.RegisterContentType
RegisterModel                 = API.RegisterModel
-- ========================================================================= --
_QuestModel                   = RegisterModel(QuestModel, "quests-data")
-- ========================================================================= --
RequestLoadQuestByID          = C_QuestLog.RequestLoadQuestByID
GetQuestName                  = QuestUtils_GetQuestName
IsWorldQuest                  = QuestUtils_IsQuestWorldQuest
IsRaidQuest                   = Utils.Quest.IsRaidQuest
IsDungeonQuest                = Utils.Quest.IsDungeonQuest
SelectQuestLogEntry           = SelectQuestLogEntry
GetNumQuestObjectives         = C_QuestLog.GetNumQuestObjectives
IsQuestBounty                 = Utils.Quest.IsQuestBounty_CrossSupport
IsQuestTask                   = Utils.Quest.IsQuestTask_CrossSupport
IsQuestTrivial                = C_QuestLog.IsQuestTrivial
GetQuestDifficultyLevel       = C_QuestLog.GetQuestDifficultyLevel
-- ========================================================================= --
-- Function with cross Support (8.3 & Shadowlands)
-- TODO: Need later to edit these function when the prepatch hits live 
-- servers
-- ========================================================================= --
IsQuestWatched                = Utils.Quest.IsQuestWatched_CrossSupport
GetNumQuestWatches            = Utils.Quest.GetNumQuestWatches_CrossSupport
GetNumQuestLogEntries         = Utils.Quest.GetNumQuestLogEntries_CrossSupport
GetQuestLogIndexByID          = Utils.Quest.GetQuestLogIndexByID_CrossSupport
GetInfo                       = Utils.Quest.GetInfo_CrossSupport
IsLegendaryQuest              = Utils.Quest.IsLegendaryQuest_CrossSupport
GetDistanceSqToQuest          = Utils.Quest.GetDistanceSqToQuest_CrossSupport
IsQuestBounty                 = Utils.Quest.IsQuestBounty_CrossSupport
IsQuestTask                   = Utils.Quest.IsQuestTask_CrossSupport
IsComplete                    = Utils.Quest.IsComplete_CrossSupport
-- ========================================================================= --
-- Shadowlands Only function
-- Don't use them in non Shadowlands environments
-- ========================================================================= --
GetRequiredMoney              = C_QuestLog.GetRequiredMoney
GetSuggestedGroupSize         = C_QuestLog.GetSuggestedGroupSize
GetTimeAllowed                = C_QuestLog.GetTimeAllowed
IsOnMap                       = C_QuestLog.IsOnMap
-- ========================================================================= --
-- NEED CHECK these below functions 
GetQuestProgressBarPercent    = GetQuestProgressBarPercent
GetQuestObjectiveInfo         = GetQuestObjectiveInfo
GetQuestLogCompletionText     = GetQuestLogCompletionText
SelectQuestLogEntry           = SelectQuestLogEntry
GetQuestLogSpecialItemInfo    = GetQuestLogSpecialItemInfo
-- ========================================================================= --
-- Register the achievements content type
-- ========================================================================= --
RegisterContentType({
  ID = "quests",
  DisplayName = "Quests",
  Description = "Track the watched quests",
  DefaultModel = _QuestModel,
  DefaultViewClass = QuestsContentView,
  Events = { "PLAYER_ENTERING_WORLD", "QUEST_WATCH_LIST_CHANGED"},
  Status = function() return GetNumQuestWatches() > 0 end
})
-- ========================================================================= --
DISTANCE_UPDATER_ENABLED      = false
QUESTS_CACHE                  = {}
QUEST_HEADERS_CACHE           = {}
QUESTS_WITH_PROGRESS          = {}
-- ========================================================================= --
__ActiveOnEvents__ "PLAYER_ENTERING_WORLD" "QUEST_WATCH_LIST_CHANGED"
function ActivateOn(self, event, ...)
  return GetNumQuestWatches() > 0
end
-- ========================================================================= --
__Async__()
function OnActive(self)
  if self:IsActivateByEvent("PLAYER_ENTERING_WORLD") then 
    local initialLogin = self:GetActivatingEventArgs()
    if initialLogin then 
      -- If it's the first login, we need to wait "QUEST_LOG_UPDATE" is fired
      -- to get valid informations about quests
      Wait("QUEST_LOG_UPDATE")
    end
  end

  _M:LoadQuests()
end

function OnInactive(self)
  _QuestModel:ClearData()
  
  wipe(QUESTS_CACHE)
  wipe(QUESTS_WITH_PROGRESS)
end
-- ========================================================================= --
function LoadQuests(self)
  local numEntries, numQuests = GetNumQuestLogEntries()
  local currentHeader = "Misc"

  for i = 1, numEntries do 
    local title, questLogIndex, questID, campaignID, level, difficultyLevel, 
      suggestedGroup, frequency, isHeader, isCollapsed, startEvent, isTask,
      isBounty, isStory, isScaling, isOnMap, hasLocalPOI, isHidden,
      isAutoComplete, overridesSortOrder, readyForTranslation = GetInfo(i)

    if isHeader then 
      currentHeader = title 
    elseif IsQuestWatched(IsOnShadowlands() and questID or i) and not isHidden and not isBounty and not isTask then 
      QUESTS_CACHE[questID] = true
      QUEST_HEADERS_CACHE[questID] = currentHeader

      local questData = {
        title = title,
        name = title,
        questLogIndex = questLogIndex,
        questID = questID, 
        campaignID = campaignID,
        level = level,
        suggestedGroup = suggestedGroup,
        difficultyLevel = difficultyLevel,
        isBounty = isBounty,
        isStory = isStory, 
        isScaling = isScaling, 
        isOnMap = isOnMap,
        hasLocalPOI = hasLocalPOI,
        isHidden = isHidden,
        isAutoComplete = isAutoComplete,
        overridesSortOrder = overridesSortOrder,
        readyForTranslation = readyForTranslation,
        header = currentHeader,
        category = currentHeader, 
      }

      _QuestModel:SetQuestData(questID, questData)

      RequestLoadQuestByID(questID)
    end 
  end

  _QuestModel:Flush()
end

function UpdateQuest(self, questID)
  -- Cross function & unchanged fonction
  local title = GetQuestName(questID)
  local level = GetQuestDifficultyLevel(questID)
  local header = self:GetQuestHeader(questID)
  local questLogIndex = GetQuestLogIndexByID(questID)
  local numObjectives = GetNumQuestObjectives(questID)
  local isComplete = IsComplete(questID)
  local isTask = IsQuestTask(questID)
  local isBounty = IsQuestBounty(questID)
  local distance = GetDistanceSqToQuest(questID)
  local isDungeon = IsDungeonQuest(questID)
  local isRaid = IsRaidQuest(questID)
  if distance then 
    distance = math.sqrt(distance)
  end

  -- Different Logic but there equivalents for 8.3 & Shadowlands
  local requiredMoney
  local failureTime
  local timeElapsed
  local isOnMap
  local hasLocalPOI
  local isLegendary

  -- REVIEW: No Equivalent for Shadowlands ?
  local questType
  local isStory
  local startEvent
  local isAutoComplete

  -- REVIEW: No Equivalent for 8.3 ?
  local suggestedGroup

  if IsOnShadowlands() then 
    requiredMoney             = GetRequiredMoney(questID)
    failureTime, timeElapsed  = GetTimeAllowed(questID)
    suggestedGroup            = GetSuggestedGroupSize(questID)
    isOnMap, hasLocalPOI      = IsOnMap(questID)
  else
    local questWatchIndex = GetQuestWatchIndex(questLogIndex)
    if not questWatchIndex then 
      return 
    end

    _, _, _, _, requiredMoney, _, startEvent, isAutoComplete, failureTime, timeElapsed,
    questType, isTask, isBounty, isStory, isOnMap, hasLocalPOI = GetQuestWatchInfo(questWatchIndex)
  end

  local questData = {
    questID         = questID,
    title           = title,
    name            = title,
    level           = level,
    header          = header,
    category        = header,
    questLogIndex   = questLogIndex,
    numObjectives   = numObjectives,
    isComplete      = isComplete,
    isTask          = isTask,
    isBounty        = isBounty,
    requiredMoney   = requiredMoney,
    failureTime     = failureTime,
    isOnMap         = isOnMap,
    hasLocalPOI     = hasLocalPOI,
    questType       = questType,
    tag             = questType,
    isStory         = isStory,
    startEvent      = startEvent,
    isAutoComplete  = isAutoComplete,
    suggestedGroup  = suggestedGroup,
    distance        = distance,
    isDungeon       = isDungeon,
    isRaid          = isRaid,
    isLegendary     = isLegendary
  }

  -- Is the quest has an item quest ?
  local itemLink, itemTexture = GetQuestLogSpecialItemInfo(questLogIndex)

  if itemLink and itemTexture then
    questData.item = {
      link    = itemLink,
      texture = itemTexture
    }
  end 

  -- Fetch the objectives
  if numObjectives > 0 then
    local objectivesData = {}
    for index = 1, numObjectives do 
      for index = 1, numObjectives do 
        local text, type, finished = GetQuestObjectiveInfo(questID, index, false)
        local data = {
          text = text,
          type = type, 
          isCompleted = finished
        }
      
        if type == "progressbar" then
          local progress = GetQuestProgressBarPercent(questID)
          data.hasProgressBar = true
          data.progress = progress
          data.minProgress = 0
          data.maxProgress = 100
          data.progressText = PERCENTAGE_STRING:format(progress)
          QUESTS_WITH_PROGRESS[questID] = true
        else 
          QUESTS_WITH_PROGRESS[questID] = nil 
        end

        objectivesData[index] = data
      end 
    end

    questData.objectives = objectivesData
  else
    if IsOnShadowlands() then 
      C_QuestLog.SetSelectedQuest(questID)
    else 
      SelectQuestLogEntry(questLogIndex)
    end
    local text = GetQuestLogCompletionText()
    questData.objectives = {
      [1] = {
        text = text,
        isCompleted = false
      }
    }
  end 
  
  _QuestModel:AddQuestData(questID, questData)
end


function QUESTS_UPDATE()
  for questID in pairs(QUESTS_CACHE) do
    _M:UpdateQuest(questID)
  end

  _QuestModel:Flush()
end


__SystemEvent__ "ZONE_CHANGED" "ZONE_CHANGED_NEW_ARED" "AREA_POIS_UPDATED"
function QUESTS_ON_MAP_UPDATE()
  QUESTS_UPDATE()

  _M:UpdateDistance()
end

__Async__()
__SystemEvent__()
function QUEST_WATCH_LIST_CHANGED(questID, isAdded)
  if not questID then 
    return 
  end 

  if isAdded then 
    QUESTS_CACHE[questID] = true 
    RequestLoadQuestByID(questID)

    _M:UpdateQuest(questID)
  else 
    QUESTS_CACHE[questID] = nil 

    _QuestModel:RemoveQuestData(questID)
    _QuestModel:Flush()
  end 
end

__SystemEvent__()
function QUEST_DATA_LOAD_RESULT(questID, success)
  if success then
    _M:UpdateQuest(questID)
    _QuestModel:Flush()
  end
end

__SystemEvent__()
function QUEST_LOG_UPDATE()
  for questID in pairs(QUESTS_WITH_PROGRESS) do
    _M:UpdateQuest(questID)
  end

  _QuestModel:Flush()
end


__SystemEvent__() 
__Async__()
function QUEST_WATCH_UPDATE(questID)
  -- Experiment: We need to wait the next "QUEST_LOG_UPDATE" in order to the 
  -- objectives are correctly updated.
  NextEvent("QUEST_LOG_UPDATE")
  
  _M:UpdateQuest(questID)
  _QuestModel:Flush()
end


function GetQuestHeader(self, qID)
    -- Check if the quest header is in the cache
    if QUEST_HEADERS_CACHE[qID] then
      return QUEST_HEADERS_CACHE[qID]
    end

    -- if no, fin the quest header
    local currentHeader = "Misc"
    local numEntries, numQuests = GetNumQuestLogEntries()

    for i = 1, numEntries do
      local title, _, questID, _, _, _, _, _, isHeader = GetInfo(i)
      if isHeader then
        currentHeader = title
      elseif questID == qID then
        QUEST_HEADERS_CACHE[qID] = currentHeader
        return currentHeader
      end
    end
    return currentHeader
end

__Async__()
__SystemEvent__()
function PLAYER_STARTED_MOVING()
  DISTANCE_UPDATER_ENABLED = true
  while  DISTANCE_UPDATER_ENABLED do
    _M:UpdateDistance()

    -- TODO: Create an option for changing the refresh rate.
    Delay(1)
  end
end

__SystemEvent__()
function PLAYER_STOPPED_MOVING()
  DISTANCE_UPDATER_ENABLED = false

  _M:UpdateDistance()
end

IN_TAXI = false
__Async__()
__SystemEvent__()
function VEHICLE_ANGLE_SHOW()
  if IN_TAXI then
    return
  end

  IN_TAXI = true

  PLAYER_STARTED_MOVING()

  NextEvent("VEHICLE_ANGLE_SHOW")

  PLAYER_STOPPED_MOVING()

  Delay(0.2)

  IN_TAXI = false
end

function UpdateDistance()
  for questID in pairs(QUESTS_CACHE) do 
    local distanceSq = GetDistanceSqToQuest(questID)
    if distanceSq then 
      _QuestModel:AddQuestData(questID, { distance = math.sqrt(distanceSq) })
    end
  end
  
  _QuestModel:Flush()
end
-- ========================================================================= --
-- Debug Utils Tools
-- ========================================================================= --
if ViragDevTool_AddData then 
  ViragDevTool_AddData(_QuestModel, "SLT Quest Model")
end
