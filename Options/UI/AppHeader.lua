-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker_Options.AppHeader"                        ""
-- ========================================================================= --
namespace                     "SLT.Options"
-- ========================================================================= --
export {
  __Recyclable__ = SLT.__Recyclable__
}
-- ========================================================================= --
local ADDON_LOGO = [[Interface\AddOns\SylingTracker_Options\Media\Textures\logo_white]]

local NAV_ITEMS_DATA = {
  [1] = { 
    id = "trackers",
    displayText = "Trackers",  
    iconPath = [[Interface\AddOns\SylingTracker_Options\Media\Textures\Icons\trackers]],
  },
  [2] = {
    id = "contents",
    displayText = "Contents",
    iconPath = [[Interface\AddOns\SylingTracker_Options\Media\Textures\Icons\contents]]
  },
  [3] = {
    id = "skins",
    displayText = "Skins",
    iconPath = [[Interface\AddOns\SylingTracker_Options\Media\Textures\Icons\skins]]
  },
  [4] = {
    id = "scripts",
    displayText = "Scripts",
    iconPath = [[Interface\AddOns\SylingTracker_Options\Media\Textures\Icons\scripts]]
  },
  [5] = {
    id = "filters",
    displayText = "Filters",
    iconPath = [[Interface\AddOns\SylingTracker_Options\Media\Textures\Icons\filters]]
  },
  [6] = {
    id = "profils",
    displayText = "Profils",
    iconPath = [[Interface\AddOns\SylingTracker_Options\Media\Textures\Icons\profils]]
  }
}

__Recyclable__ "SylingTracker_Options_AppNavBarItem%d"
class "AppNavBarItem" (function(_ENV)
  inherit "Button"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------
  local function UpdateIconHandler(self, new)
    Style[self].NormalTexture.file = new
    Style[self].HighlightTexture.file = new
  end

  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "IconPath" { 
    type = String,
    handler = UpdateIconHandler
  }

  property "ID" {
    type = Number + String 
  }

  property "DisplayText" {
    type = String,
    default = ""
  }

  function __ctor(self) end


end)


local navData = {
  [1] = { displayText = "Trackers", id = "tracker", iconPath = [[]]}
}

class "AppNavBar" (function(_ENV)
  inherit "Frame"
  -----------------------------------------------------------------------------
  --                               Handlers                                  --
  -----------------------------------------------------------------------------


  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function BuildNavIcons(self)
    local itemContainer = self:GetChild("IconContainer")
    local previousItem

    local totalWidth = 0
    for index, itemData in ipairs(NAV_ITEMS_DATA) do 
      local item = self.ItemClass.Acquire()
      item:SetParent(itemContainer)
      item:InstantApplyStyle()

      item.ID = itemData.id
      item.DisplayText = itemData.displayText 
      item.IconPath = itemData.iconPath
      item.OnEnter = item.OnEnter + self.OnItemEnter
      item.OnLeave = item.OnLeave + self.OnItemLeave

      totalWidth = totalWidth + item:GetWidth()

      if index == 1 then 
        item:SetPoint("LEFT")
      else 
        item:SetPoint("LEFT", previousItem, "RIGHT", self.ItemSpacing, 0)
        totalWidth = totalWidth + self.ItemSpacing
      end 

      previousItem = item
    end

    self:SetWidth(totalWidth)
  end 

  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "NavData" {
    type = Table, 
    handler = UpdateNavData
  }

  property "ItemClass" {
    type = ClassType,
    default = AppNavBarItem
  }

  property "ItemSpacing" {
    type = Number, 
    default = 8
  }

  __Template__{
    IconContainer = Frame,
    Text = SLT.SLTFontString
  }
  function __ctor(self) 
    self.OnItemEnter = function(item)
      Style[self].Text.text = item.DisplayText
    end

    self.OnItemLeave = function() Style[self].Text.text = "" end

    self:BuildNavIcons()
  end

end)



class "AppHeader" (function(_ENV)
  inherit "Frame"


  __Template__{
    HomeButton = SLTButton,
    BottomSeparator = Texture,
    NavBar = AppNavBar
  }
  function __ctor(self)

  end


end)
-- ========================================================================= --
--                                Styles                                     --
-- ========================================================================= --
Style.UpdateSkin("Default", {
  [AppNavBarItem] = {
    width = 24,
    height = 24,

    hitRectInsets = {
      top = -4,
      left = -4,
      right = -4,
      bottom = -4
    },

    NormalTexture = {
      vertexColor = { r = 1, g = 1, b = 1, a = 0.55},
      setAllPoints = true
    },

    HighlightTexture = {
      vertexColor = { r = 1, g = 1, b = 1, a = 0.15},
      setAllPoints = true
    }
  },

  [AppNavBar] = {
    IconContainer = {
      height = 24,

      location = {
        Anchor("TOP"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    },

    Text = {
      text = "Skins",
      sharedMediaFont = FontType("PT Sans Narrow Bold", 16),
      textColor = Color(0.9, 0.9, 0.9, 0.5),
      justifyH = "CENTER",
      location = {
        Anchor("TOP", 0, 0, "IconContainer", "BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT"),
        Anchor("BOTTOM")
      }
    }
  },

  [AppHeader] = {
    height = 64,

    HomeButton = {
      width = 44,
      height = 44,

      location = {
        Anchor("TOP", 0, -5),
        Anchor("LEFT", 5, 0)
      },

      NormalTexture = {
        file = ADDON_LOGO,
        vertexColor = { r = 1, g = 1, b = 1, a = 0.5 },
        setAllPoints = true,
      }
    },

    NavBar = {
      location = {
        Anchor("TOP"),
        Anchor("BOTTOM")
      }
    },

    BottomSeparator = {
      height = 1,
      file = [[Interface\Buttons\WHITE8X8]],
      vertexColor = { r = 1, g = 1, b = 1, a = 0.15 },
      location = {
        Anchor("BOTTOM"),
        Anchor("LEFT"),
        Anchor("RIGHT")
      }
    }
  }
})
