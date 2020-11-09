-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker_Options.AppWindow"                        ""
-- ========================================================================= --
namespace                     "SLT.Options"
-- ========================================================================= --

__Recyclable__ "SylingTracker_Options_AppWindow%d"
class "AppWindow" (function(_ENV)
  inherit "Frame"

  enum "AppNavigationCategory" {
    "Home",
    "Trackers",
    "Contents",
    "Skins",
    "Scripts",
    "Filters",
    "Profils"
  }

  __Arguments__ { AppNavigationCategory }
  function SelectCategory(self, category)

  end

  __Template__{
    Header = AppHeader,
    Footer = AppFooter,
    CloseButton = Button,
  }
  function __ctor(self)

  end
end)
-- ========================================================================= --
--                                Styles                                     --
-- ========================================================================= --
Style.UpdateSkin("Default", {
  [AppWindow] = {
    width = 1150,
    height = 775,
    backdrop = {
      bgFile = [[Interface\AddOns\SylingTracker_Options\Background]]
    },

    -- Children
    CloseButton = {
      width = 24,
      height = 24,

      NormalTexture = {
        file = [[Interface\AddOns\SylingTracker_Options\Media\Textures\Icons\close]],
        vertexColor = { r = 1, g = 0, b = 0, a = 0.5},
        setAllPoints = true,
      },
      HighlightTexture = {
        file = [[Interface\AddOns\SylingTracker_Options\Media\Textures\Icons\close]],
        vertexColor = { r = 1, g = 0, b = 0, a = 0.15},
        setAllPoints = true,
      },

      location = {
        Anchor("TOPRIGHT", -5, -5)
      }
    },

    Header = {
      location = {
        Anchor("TOP", 0, -5),
        Anchor("LEFT", 5, 0),
        Anchor("RIGHT", -5, 0)
      }
    },

    Footer = {
      location = {
        Anchor("BOTTOM", 0, 5),
        Anchor("LEFT", 5, 0),
        Anchor("RIGHT", -5, 0)
      }
    }
  }
})


function OnLoad(self)
  _AppWindow = AppWindow("SylingTracker_Options", UIParent)
  _AppWindow:SetPoint("CENTER")
end