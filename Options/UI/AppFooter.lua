-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling              "SylingTracker_Options.AppFooter"                        ""
-- ========================================================================= --
namespace                     "SLT.Options"
-- ========================================================================= --
local ADDON_LOGO = [[Interface\AddOns\SylingTracker_Options\Media\Textures\logo_white]]

class "AppFooter" (function(_ENV)
  inherit "Frame"

  __Template__{
    AddonName = SLT.SLTFontString,
    AddonLogo = Texture,
    AddonVersion = SLT.SLTFontString
  }
  function __ctor(self)

  end
end)
-- ========================================================================= --
--                                Styles                                     --
-- ========================================================================= --
Style.UpdateSkin("Default", {
  [AppFooter] = {
    height = 36,
    backdrop = {
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient2]],
      edgeFile = [[Interface\Buttons\WHITE8X8]],
      edgeSize = 1  
    },

    backdropColor = { r = 48/255, g = 48/255, b = 48/255, a = 0.25 },
    backdropBorderColor = { r = 1, g = 1, b = 1, a = 0.15},

    -- Children properties
    -- AddonName = {
    --   text = "Syling Tracker",
    --   textTransform   = "UPPERCASE",
    --   sharedMediaFont = FontType("PT Sans Narrow Bold", 14),
    --   textColor = Color(0.9, 0.9, 0.9, 0.35),

    --   location = {
    --     Anchor("LEFT", 5, 0)
    --   }
    -- },

    AddonLogo = {
      width = 32,
      height = 32,
      file = ADDON_LOGO,
      vertexColor = { r = 1, g = 1, b = 1, a = 0.35},

      location = {
        Anchor("LEFT", 5, 0)
      }


    },

    AddonVersion = {
      text = "version: 1.0.0",
      sharedMediaFont = FontType("PT Sans Narrow Bold", 13),
      textColor = Color(0.9, 0.9, 0.9, 0.35),
      location = {
        Anchor("LEFT", 5, 0, "AddonLogo", "RIGHT")
      }
    }
  }
})
