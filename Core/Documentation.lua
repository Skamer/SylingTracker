-- ========================================================================= --
--                              SylingTracker                                --
--           https://www.curseforge.com/wow/addons/sylingtracker             --
--                                                                           --
--                               Repository:                                 --
--                   https://github.com/Skamer/SylingTracker                 --
--                                                                           --
-- ========================================================================= --
Syling                  "SylingTracker.Core.Documentation"
-- ========================================================================= --
namespace                          "SLT"
-- ========================================================================= --
struct "FlagDoc" (function(_ENV)
  member "value" { TYPE = Number + String }
  member "displayName" { type = String }
  member "description" { type = String }
end)

struct "StateDoc" (function(_ENV)
  member "value" { TYPE = Number + String }
  member "displayName" { type = String }
  member "description" { type = String }
end)

class "FrameDoc" (function(_ENV)

  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  __Arguements__ { ClassType * 0 }
  function InheritsDocs(self, ...)

  end

  __Arguements__ { FlagDoc }
  function AddFlag(self, doc)

  end

  __Arguements__ { StateDoc }
  function AddState()

  end
  
  -- { doc: , children: }
  __Arguements__{ (String + Number ) * 0}
  function SetParentIndex(self, ...)

  end


  function AddChild(self, childIndex, childDoc)
    if self.__CurrentParentIndex then 

    else 

    end
  end

  -----------------------------------------------------------------------------
  --                               Properties                                --
  -----------------------------------------------------------------------------
  property "ParentDocs" {
    default = function() return Array[ClassType]() end 
  }

  property "Children" {
    default = function() return {} end 
  }

  property "Flags" {
    default = function() Array[FlagDoc]() end 
  }

  property "States" {
    default = function() Array[StateDoc]() end
  }

end)


class "Documentation" (function(_ENV)
  _Doc 

  -----------------------------------------------------------------------------
  --                               Methods                                   --
  -----------------------------------------------------------------------------
  function __exist()
    return _Doc
  end
  -----------------------------------------------------------------------------
  --                            Constructors                                 --
  -----------------------------------------------------------------------------
  function __ctor(self)
    _Doc = self 
  end

end)