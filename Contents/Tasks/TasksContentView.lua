-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                   "SylingTracker.Tasks.ContentView"                   ""
-- ========================================================================= --
namespace                           "SLT"
-- ========================================================================= --
export {
  ValidateFlags                     = System.Toolset.validateflags,
  ResetStyles                       = Utils.ResetStyles
}
-- ========================================================================= --
__Recyclable__ "SylingTracker_TasksContentView%d"
class "TasksContentView" (function(_ENV)
  inherit "ContentView"

  __Flags__()
  enum "Flags" {
    NONE      = 0,
    HAS_TASKS = 1
  }
  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function OnViewUpdate(self, data)
    local questsData = data.quests

    -- Determines the flags 
    local flags = Flags.NONE
    if questsData then 
      flags = Flags.HAS_TASKS
    end

    if flags ~= self.Flags then
      ResetStyles(self)

      -- are there world quests 
      if ValidateFlags(Flags.HAS_TASKS, flags) then 
        self:AcquireTasks()
      else
        self:ReleaseTasks()
      end

      -- Styling stuff 
      if flags ~= Flags.NONE then 
        local styles = self.FlagsStyles and self.FlagsStyles[flags]
        if styles then 
          Style[self] = styles
        end
      end
    end

    -- Update 
    if questsData then 
      local tasksView = self:AcquireTasks()
      tasksView:UpdateView(questsData)
    end

    self.Flags = flags
  end

  function AcquireTasks(self)
    local content = self:GetChild("Content")
    local tasks = content:GetChild("Tasks")
    if not tasks then 
      tasks = TaskListView.Acquire()

      -- We need to keep the old name when we'll release it 
      self.__PreviousTasksName = tasks:GetName()

      tasks:SetParent(content)
      tasks:SetName("Tasks")
      tasks:InstantApplyStyle()

      -- Register the vents 
      tasks.OnSizeChanged = tasks.OnSizeChanged + self.OnTasksSizeChanged

      self:AdjustHeight(true)
    end

    return tasks
  end

  function ReleaseTasks(self)
    local content = self:GetChild("Content")
    local tasks = content:GetChild("Tasks")
    if tasks then 
      -- Give its old name (generated by the recycle system)
      tasks:SetName(self.__PreviousTasksName)
      self.__PreviousTasksName = nil

      -- Unregister the events 
      tasks.OnSizeChanged = tasks.OnSizeChanged - self.OnTasksSizeChanged

      -- It's better to release it after the event has been unregistered for avoiding
      -- useless call 
      tasks:Release()

      self:AdjustHeight(true)
    end
  end

  function OnRelease(self)
    self:ReleaseTasks()

    -- We call the "Parent" onRelease (see, ContentView)
    super.OnRelease(self)

    -- Reset property
    self.Flags = nil 
  end
  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "FlagsStyles" {
    type = Table
  }

  property "Flags" {
    type    = TasksContentView.Flags,
    default = TasksContentView.Flags.NONE
  }
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  __Template__{}
  function __ctor(self)
    self.OnTasksSizeChanged = function() self:AdjustHeight(true) end
  end
end)
-- ========================================================================= --
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
    
    Content = {
      location = {
        Anchor("TOP", 0, -5, "Header", "BOTTOM"),
        Anchor("LEFT", 5, 0),
        Anchor("RIGHT", -5, 0)
      }   
    },

    FlagsStyles = {
      [TasksContentView.Flags.HAS_TASKS] = {
        Content = {
          Tasks = {
            location = {
              Anchor("TOP"),
              Anchor("LEFT"),
              Anchor("RIGHT")
            }               
          }
        }
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
