Scorpio "SylingTracker_Options.SLTButton" ""

namespace "SLT.Options"


class "SLTButton" (function(_ENV)
  inherit "Button"

  __Template__ {
    Icon = Texture
  }
  function __ctor()

  end

end)

Style.UpdateSkin("Default", {

  [SLTButton] = {
    width = 32,
    height = 32,

    backdrop = {
      bgFile = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient2]],
      edgeFile = [[Interface\Buttons\WHITE8X8]],
      edgeSize = 1
    },

    HighlightTexture = {
      file = [[Interface\AddOns\SylingTracker\Media\Textures\LinearGradient]],
      vertexColor = { r = 1, g = 1, b = 1, a = 0.1},
      setAllPoints = true,
    },

    backdropColor = { r = 48/255, g = 48/255, b = 48/255, a = 0.15 },
    backdropBorderColor = { r = 1, g = 1, b = 1, a = 0.15},

    Icon = {
      location = {
        Anchor("CENTER")
      }

      -- atlas = AtlasType("Dungeon", true)

    }

    
  }
})