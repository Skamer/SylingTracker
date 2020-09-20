-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Scorpio                   "SylingTracker.Tasks.ContentView"                  ""
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
__Recyclable__ "SylingTracker_TasksContentView%d"
class "TasksContentView" (function(_ENV)
  inherit "Frame" extend "IView"
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data)
    if data.quests then 
      local tasks = self:AcquireTasks()
      tasks:UpdateView(data.quests, updater)
    else 
      self:ReleaseTasks()
    end
  end


  function OnAdjustHeight(self, useAnimation)
    local height = 0
    local maxOuterBottom 

    for childName, child in self:GetChilds() do 
      local outerBottom = child:GetBottom() 
      if outerBottom then 
        if not maxOuterBottom or maxOuterBottom > outerBottom then 
          maxOuterBottom = outerBottom
        end 
      end 
    end
    
    if maxOuterBottom then 
      local computeHeight = self:GetTop() - maxOuterBottom + self.PaddingBottom
      if useAnimation then 
        self:SetAnimatedHeight(computeHeight)
      else 
        self:SetHeight(computeHeight)
      end
    end
  end

  function AcquireTasks(self)
    local tasks = self:GetChild("Tasks")
    if not tasks then 
      tasks = TaskListView.Acquire()

      -- We need to keep the old name when we'll release it 
      self.__previousTasksName = tasks:GetName()

      tasks:SetParent(self)
      tasks:SetName("Tasks")

      -- It's important to style only when we have set its parent and its name
      if self.Tasks then 
        Style[tasks] = self.Tasks 
      end

      -- Register the vents 
      tasks.OnSizeChanged = tasks.OnSizeChanged + self.OnTasksSizeChanged

      self:AdjustHeight(true)
    end

    return tasks
  end

  function ReleaseTasks(self)
    local tasks = self:GetChild("Tasks")
    if tasks then 
      -- Give its old name (generated by the recycle system)
      tasks:SetName(self.__previousTasksName)

      -- Unregister the events 
      tasks.OnSizeChanged = tasks.OnSizeChanged - self.OnTasksSizeChanged

      -- It's better to release it after the event has been unregistered for avoiding
      -- useless call 
      tasks:Release()

      self:AdjustHeight()
    end
  end

  function OnRelease(self)
    self:ReleaseTasks()

    self:ClearAllPoints()
    self:SetParent()
    self:Hide()
    self:CancelAdjustHeight()
    self:CancelAnimatingHeight()

    self:SetHeight(1)
  end

  function OnAcquire(self)
    -- Important ! We need the frame is instantly styled as this may affect 
    -- its height.
    self:InstantApplyStyle()

    self:Show()

    self:AdjustHeight(true)
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "PaddingBottom" {
    type    = Number,
    default = 10
  }

  -- The style used for tasks
  property "Tasks" {
    type = Table
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{
    Header = ContentHeader
    -- Tasks = TaskListView
  }
  function __ctor(self)
    -- -- Important ! We need the frame is instantly styled as this may affect 
    -- -- its height.
    -- self:InstantApplyStyle()

    -- self:SetClipsChildren(true)

    -- Important! As the frame ajusts its height depending of its children height
    -- we need to set its height when contructed for the event "OnSizechanged" of
    -- its children is triggered.
    self:SetHeight(1) -- !important

    -- local quests = self:GetChild("Tasks")

    -- quests.OnSizeChanged = function(...)
    --     self:AdjustHeight(true)
    -- end

    self.OnTasksSizeChanged = function() self:AdjustHeight(true) end

    self:SetClipsChildren(true)
  end
end)

-- Create the same thing for bonus tasks (also known as bonus objectives)
__Recyclable__ "SylingTracker_BonusTasksContentView%d"
class "BonusTasksContentView" { TasksContentView }


-------------------------------------------------------------------------------
--                                Styles                                     --
-------------------------------------------------------------------------------
Style.UpdateSkin("Default", {
  [TasksContentView] = {
    Header = {
      height = 32,
      location = {
        Anchor("TOPLEFT"),
        Anchor("TOPRIGHT")
      },
      IconBadge = {
        backdropColor = { r = 0, g = 0, b = 0, a = 0},
        Icon = {
          atlas = AtlasType("QuestBonusObjective")
        }
      },

      Label = {
        text = TRACKER_HEADER_OBJECTIVE
      } 
    },
    Tasks = {
      location = {
        Anchor("TOP", 0, -5, "Header", "BOTTOM"),
        Anchor("LEFT", 4, 0),
        Anchor("RIGHT", -4, 0)
      }   
    }
  },

  [BonusTasksContentView] = {
    Header = {
      Label = {
        text = TRACKER_HEADER_BONUS_OBJECTIVES
      }
    }
  }
})