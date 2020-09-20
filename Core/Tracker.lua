-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Scorpio                     "SylingTracker.Core.Tracker"                     ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
local function OnMinMaxValueSet(self)
    local height    = self:GetHeight()
 
    if not height then return end
 
    local min, max  = self:GetMinMaxValues()
    local value     = self:GetValue()
 
    local width     = self:GetPropertyChild("ThumbTexture"):GetWidth()
 
    Style[self].thumbTexture.size = Size(width, math.max(24, height - (max - min)))
end
 
 
UI.Property         {
    name            = "ThumbAutoHeight",
    type            = Boolean,
    require         = { Slider },
    default         = false,
    set             = function(self, auto)
        if auto then
            if not _M:GetSecureHookHandler(self, "SetMinMaxValues") then
                _M:SecureHook(self, "SetMinMaxValues", OnMinMaxValueSet)
            end
        else
            if _M:GetSecureHookHandler(self, "SetMinMaxValues") then
                _M:SecureUnHook(self, "SetMinMaxValues")
            end
        end
    end,
}

class "Tracker"(function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function OnScrollRangeChanged(self, xrange, yrange)
    --if self.NoAutoAdjustScrollRange then return end
    local scrollFrame = self:GetChild("ScrollFrame")
    local scrollBar   = self:GetChild("ScrollBar")

    yrange                  = math.floor(yrange or scrollFrame:GetVerticalScrollRange())

    scrollBar:InstantApplyStyle()
    scrollBar:SetMinMaxValues(0, yrange)
    scrollBar:SetValue(math.min(scrollBar:GetValue(), yrange))
  end

  local function OnVerticalScroll(self, offset)
    self:GetChild("ScrollBar"):SetValue(offset)
  end
  
  local function OnMouseWheel(self, value)
    self:GetChild("ScrollBar"):OnMouseWheel(value)
  end 

  -- local function OnViewSizeChanged(self)
  --   self:GetParent():AdjustHeight()
  -- end

  -- local function OnViewOrderChanged(self)
  --   self:GetParent():AdjustHeight()
  -- end 

  -- NOTE: Required
  function SetVerticalScroll(self, value)
    self:GetChild("ScrollFrame"):SetVerticalScroll(value)
  end
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguments__ { String + Number }
  function TrackContentType(self, contentID)
    Scorpio.FireSystemEvent("SLT_TRACKER_TRACK_CONTENT_TYPE", self, contentID)
  end
  
  __Arguments__ { String + Number }
  function UntrackContentType(self, contentID)
    Scorpio.FireSystemEvent("SLT_TRACKER_UNTRACK_CONTENT_TYPE", self, contentID)
  end

  __Arguments__ { IView }
  function AddView(self, view)
    self.Views:Insert(view)
    view:SetParent(self:GetChild("ScrollFrame"):GetChild("Content"))

    -- Register the events
    view.OnSizeChanged = view.OnSizeChanged + self.OnViewSizeChanged
    view.OnOrderChanged = view.OnOrderChanged + self.OnViewOrderChanged

    self:Layout()
    self:AdjustHeight()
  end

  __Arguments__ { IView }
  function RemoveView(self, view)
    self.Views:Remove(view)

    -- Unregister the events
    view.OnSizeChanged = view.OnSizeChanged - self.OnViewSizeChanged
    view.OnOrderChanged = view.OnOrderChanged - self.OnViewOrderChanged

    self:Layout()
    self:AdjustHeight()

    -- NOTE: We don't call the "Release" method of view because it will be done by
    -- the content type.
  end 

  function OnLayout(self)
    local content = self:GetChild("ScrollFrame"):GetChild("Content")
    local previousView

    for index, view in self.Views:Sort("x,y=>x.Order<y.Order"):GetIterator() do
      if index > 1 then 
        view:SetPoint("TOP", previousView, "BOTTOM", 0, -self.Spacing)
        view:SetPoint("LEFT")
        view:SetPoint("RIGHT")
      else 
        view:SetPoint("TOP")
        view:SetPoint("LEFT")
        view:SetPoint("RIGHT")
      end

      previousView = view
    end
  end

  function Layout(self)
    if not self._pendingLayout then 
      self._pendingLayout = true 

      Scorpio.Delay(0.1, function() 
        local aborted = false
        if self._cancelLayout then 
          aborted = self._cancelLayout 
        end

        if not aborted then 
          self:OnLayout()
        end

        self._pendingLayout = nil
        self._cancelLayout = nil
      end)
    end 
  end

  function CancelLayout(self)
    if self._pendingLayout then 
      self._cancelLayout = true
    end
  end

  function OnAdjustHeight(self)
    local height = 0
    local count = 0
    local content = self:GetChild("ScrollFrame"):GetChild("Content")
    for _, view in self.Views:GetIterator() do 
      count = count + 1
      height  = height + view:GetHeight()
    end
    
    height = height + self.Spacing * math.max(0, count-1)

    content:SetHeight(height)
  end 

  --- This is helper function will call "OnAdjustHeight".
  --- This is safe to call it multiple time in short time, resulting only a one 
  --- call of "OnAdjustHeight"
  function AdjustHeight(self)
    if not self._pendingAdjustHeight then 
      self._pendingAdjustHeight = true 

      Scorpio.Delay(0.1, function() 
        local aborted = false
        if self._cancelAdjustHeight then 
          aborted = self._cancelAdjustHeight 
        end

        if not aborted then 
          self:OnAdjustHeight()
        end

        self._pendingAdjustHeight = nil
      end)
    end 
  end

  --- Cancel the "OnAdjustHeight" call if there is one in queue.
  --- You probably do when the obj is releasing.
  function CancelAdjustHeight(self)
    if self._pendingAdjustHeight then 
      self._cancelAdjustHeight = true
    end
  end

  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "Views" {
    default = function() return Array[IView]() end
  }

  property "Spacing" {
    type = Number,
    default = 10
  }

  property "ID" {
    type = Number + String
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    ScrollFrame = ScrollFrame,
    ScrollBar = UIPanelScrollBar,
    Resizer = Resizer,
    {
      ScrollFrame = {
        Content = Frame
      }
    }
  }
  function __ctor(self)

    local scrollFrame = self:GetChild("ScrollFrame")
    scrollFrame:SetClipsChildren(true)
    
    scrollFrame.OnScrollRangeChanged = scrollFrame.OnScrollRangeChanged + function(_, xrange, yrange)
      OnScrollRangeChanged(self, xrange, yrange)
    end

    scrollFrame.OnVerticalScroll = scrollFrame.OnVerticalScroll + function(_, offset)
      OnVerticalScroll(self, offset)
    end
    
    scrollFrame.OnMouseWheel = scrollFrame.OnMouseWheel + function(_, value)
      OnMouseWheel(self, value)
    end

    scrollFrame:InstantApplyStyle()

    local content = scrollFrame:GetChild("Content")
    content:SetHeight(1)
    content:SetWidth(scrollFrame:GetWidth())

    scrollFrame:SetScrollChild(content)

    scrollFrame.OnSizeChanged = scrollFrame.OnSizeChanged + function(_, width) 
      content:SetWidth(width)
    end

    
    self.OnViewOrderChanged = function() self:Layout() end 
    self.OnViewSizeChanged = function() self:AdjustHeight() end 
  end 
end)


Style.UpdateSkin("Default", {
  [Tracker] = {
    size = Size(300, 325),
    resizable = false,

    -- [ScrollFrame] child properties 
    ScrollFrame = {
      SetAllPoints = true,
    },

    -- [ScrollBar] child properties
    ScrollBar = {
      thumbAutoHeight = true,
      scrollStep = 15,
      autoHide = true,
      backdropColor = ColorType(0, 0, 0, 0.3),
      width = 6,
      height = 244,
      backdrop = { bgFile = [[Interface\Buttons\WHITE8X8]] },
      location = { Anchor("LEFT", 15, 0, nil, "RIGHT") },
      thumbTexture = {
        file = [[Interface\Buttons\WHITE8X8]],
        vertexColor = ColorType(1, 199/255, 0, 0.75),
        size = Size(4, 198)
        --size = Size(4, 214),
      },

      -- ScrollBar.ScrollUpButton
      ScrollUpButton = {
        visible = false 
      },

      -- ScrollBar.ScrollDownButton
      ScrollDownButton = {
        visible = false
      }
    }
  }
})


tracer = nil

function OnLoad(self)
  tracker = Tracker("Tracker #1235")
  tracker:SetPoint("CENTER", 600, 0)
  tracker:SetParent(UIParent)
  tracker.ID = "main"

  tracker:TrackContentType("scenario")
  tracker:TrackContentType("dungeon")
  tracker:TrackContentType("achievements")
  tracker:TrackContentType("bonus-tasks")
  tracker:TrackContentType("tasks")
  tracker:TrackContentType("quests")
  tracker:TrackContentType("world-quests")

end

__SlashCmd__ "tuntrack"
function TestUnTrack(self)
  tracker:UntrackContentType("quests")
end 

__SlashCmd__ "ttrack"
function TestTrack(self)
  tracker:TrackContentType("quests")
end 

-- function OnLoad(self)
--   local tracker = Tracker("Tracker #1235")
--   tracker:SetPoint("CENTER", 600, 0)
--   tracker:SetParent(UIParent)

--   local scrollFrame = tracker:GetChild("ScrollFrame")
--   local content = scrollFrame:GetChild("Content")

--   local questOne = QuestView.Acquire()
--   tracker:AddView(questOne)
--   questOne:Update({
--     name = "A New Court",
--     completed = "text",
--     objectives = {
--       [1] = { completed = false, text = "Picky Stefan recruited"},
--       [2] = { completed = false, text = "Hips recruited"},
--       [3] = { completed = true, text = "Lord Garridan recruited"},
--       [4] = { completed = false, text = "The Accuser recruited"},
--       [5] = { completed = false, type = "progress", text = "Bat used to reach Sinfall's surface"}
--     }
--   })
--   -- questOne:Update({
--   --   name = "A New Court",
--   --   completed = "text",
--   --   objectives = {
--   --     [1] = { completed = false, text = "Picky Stefan recruited"},
--   --     [2] = { completed = false, text = "Hips recruited"},
--   --     [3] = { completed = false, text = "Lord Garridan recruited"},
--   --     [4] = { completed = false, text = "The Accuser recruited"},
--   --     [5] = { completed = true, text = "Bat used to reach Sinfall's surface"}
--   --   }
--   -- })

--   local questTwo = QuestView.Acquire()
--   tracker:AddView(questTwo)
--   questTwo:Update({
--     name = "The Rescue of Herbert Gloomburst",
--     completed = "text",
--     objectives = {
--       [1] = { completed = false, text = "Rescue Herbert Gloomburst from the harpy's necrotic ritual"}
--     }
--   })
  
--   local questThree = QuestView.Acquire()
--   tracker:AddView(questThree)
--   questThree:Update({
--     name = "The Way to Hibernal Hollow",
--     completed = "text",
--     objectives = {
--       [1] = { completed = false, text = "Recruit Niya to escort the strange wildseed to Tirna Glayn."},
--     }
--   })

--   local questFourth = QuestView.Acquire()
--   tracker:AddView(questFourth)
--   questFourth:Update({
--     name = "A Good Heart",
--     completed = "text",
--     objectives = {
--       [1] = { completed = false, text = "Heart collected"},
--       [2] = { completed = false, text = "Heart placed in Emeni's construct."}
--     }
--   })
--   local questFive = QuestView.Acquire()
--   tracker:AddView(questFive)
--   questFive:Update({
--     name = "A Call to Maldraxxus",
--     completed = "text",
--     objectives = {
--       [1] = { completed = false, text = "Defend Maldraxxus by completing Daily Quests and World Quests, looting treasures, and slaying rare creatures. You may also defeat powerful foes in the Plaguefall and Theatre of Pain dungeons."},
--     }
--   })

-- end

-- function OnLoad(self)
--   local tracker = Tracker("Tracker #1235")
--   tracker:SetPoint("CENTER", 600, 0)
--   tracker:SetParent(UIParent)

-- --   local questList = QuestListView.Acquire()
-- --   tracker:AddView(questList)
-- --   questList:Update({
-- --     [150] = {
-- --       name = "A New Court",
-- --       completed = "text",
-- --       objectives = {
-- --         [1] = { completed = false, text = "Picky Stefan recruited"},
-- --         [2] = { completed = false, text = "Hips recruited"},
-- --         [3] = { completed = true, text = "Lord Garridan recruited"},
-- --         [4] = { completed = false, text = "The Accuser recruited"},
-- --         [5] = { completed = false, type = "progress", text = "Bat used to reach Sinfall's surface"}
-- --       }
-- --     },
-- --     [350] = {
-- --       name = "A Good Heart",
-- --       completed = "text",
-- --       objectives = {
-- --         [1] = { completed = false, text = "Heart collected"},
-- --         [2] = { completed = false, text = "Heart placed in Emeni's construct."}
-- --       }
-- --     }
-- --   }
-- -- )

--   local scrollFrame = tracker:GetChild("ScrollFrame")
--   local content = scrollFrame:GetChild("Content")

--   local questOne = QuestView.Acquire()
--   tracker:AddView(questOne)
--   questOne:Update({
--     name = "A New Court",
--     completed = "text",
--     objectives = {
--       [1] = { completed = false, text = "Picky Stefan recruited"},
--       [2] = { completed = false, text = "Hips recruited"},
--       [3] = { completed = true, text = "Lord Garridan recruited"},
--       [4] = { completed = false, text = "The Accuser recruited", failed = true},
--       [5] = { completed = false, type = "progress", text = "Bat used to reach Sinfall's surface"}
--     }
--   })
--   -- questOne:Update({
--   --   name = "A New Court",
--   --   completed = "text",
--   --   objectives = {
--   --     [1] = { completed = false, text = "Picky Stefan recruited"},
--   --     [2] = { completed = false, text = "Hips recruited"},
--   --     [3] = { completed = false, text = "Lord Garridan recruited"},
--   --     [4] = { completed = false, text = "The Accuser recruited"},
--   --     [5] = { completed = true, text = "Bat used to reach Sinfall's surface"}
--   --   }
--   -- })

--   local questTwo = QuestView.Acquire()
--   tracker:AddView(questTwo)
--   questTwo:Update({
--     name = "The Rescue of Herbert Gloomburst",
--     completed = "text",
--     objectives = {
--       [1] = { completed = false, text = "Rescue Herbert Gloomburst from the harpy's necrotic ritual"}
--     }
--   })
  
--   local questThree = QuestView.Acquire()
--   tracker:AddView(questThree)
--   questThree:Update({
--     name = "The Way to Hibernal Hollow",
--     completed = "text",
--     objectives = {
--       [1] = { completed = false, text = "Recruit Niya to escort the strange wildseed to Tirna Glayn."},
--     }
--   })

--   local questFourth = QuestView.Acquire()
--   tracker:AddView(questFourth)
--   questFourth:Update({
--     name = "A Good Heart",
--     completed = "text",
--     objectives = {
--       [1] = { completed = false, text = "Heart collected"},
--       [2] = { completed = false, text = "Heart placed in Emeni's construct."}
--     }
--   })
--   local questFive = QuestView.Acquire()
--   tracker:AddView(questFive)
--   questFive:Update({
--     name = "A Call to Maldraxxus",
--     completed = "text",
--     objectives = {
--       [1] = { completed = false, text = "Defend Maldraxxus by completing Daily Quests and World Quests, looting treasures, and slaying rare creatures. You may also defeat powerful foes in the Plaguefall and Theatre of Pain dungeons."},
--     }
--   })

-- end 