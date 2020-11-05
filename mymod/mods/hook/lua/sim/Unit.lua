#****************************************************************************
#**
#**  File     :  /lua/sim/unit.lua
#**  Summary  : The Unit lua module
#**
#**  Copyright © 2008 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

SyncMeta = {
    __index = function(t,key)
        local id = rawget(t,'id')
        return UnitData[id].Data[key]
    end,

    __newindex = function(t,key,val)
        #LOG( "SYNC: " .. key .. ' = ' .. repr(val))
        local id = rawget(t,'id')
        
        if not UnitData[id] then
            UnitData[id] = {
                OwnerArmy = rawget(t,'army'),
                Data = {}
            }
        end
        UnitData[id].Data[key] = val

        if not Sync.UnitData[id] then
            Sync.UnitData[id] = {}
        end
        Sync.UnitData[id][key] = val
    end,
}

Unit = Class(moho.unit_methods) {

    # Engine Events
    OnPreCreate = function(self) 

        # Each unit has a sync table that magically knows when values change and stuffs it
        # in the global sync table to copy to the user layer at sync time.
        self.Sync = {}
        self.Sync.id = self:GetEntityId()
        self.Sync.army = self:GetArmy()
        setmetatable(self.Sync,SyncMeta)

        if not self.Trash then
            self.Trash = TrashBag()
        end
        
        if not self.TrashOnKilled then
            self.TrashOnKilled = TrashBag()
        end
    end,
    
    OnKilled = function(self, instigator, cause, overkillRatio)
        if self.TrashOnKilled then
            self.TrashOnKilled:Destroy()
        end
    end,
    
    OnDestroy = function(self)
        # Clear out our sync data
        UnitData[self:GetEntityId()] = false
        Sync.UnitData[self:GetEntityId()] = false
        
        # Don't allow anyone to stuff anything else in the table
        self.Sync = false
        
        # Let the user layer know this id is kaput
        Sync.ReleaseIds[self:GetEntityId()] = true

        if self.Trash then
            self.Trash:Destroy()
        end
    end,
    
    GetSync = function(self)
        if not Sync.UnitData[self:GetEntityId()] then 
            Sync.UnitData[self:GetEntityId()] = {} 
        end
        return Sync.UnitData[self:GetEntityId()]
    end,

    OnCreate = function(self) end,
    OnStartBeingBuilt = function(self,creator,layer) end,
    OnStopBeingBuilt = function(self,creator,layer) end,
    OnAutoModeOn = function(self) end,
    OnAutoModeOff = function(self) end,
    OnPaused = function(self) end,
    OnUnpaused = function(self) end,
    OnStartRepeatQueue = function(self) end,
    OnStopRepeatQueue = function(self) end,
    OnScriptBitClear = function(self,bit) end,
    OnScriptBitSet = function(self,bit) end,
    OnAssignedFocusEntity = function(self) end,
    CheckCanBeKilled = function(self) return true end,
    OnDecayed = function(self) end,
    OnTerrainTypeChange = function(self,new,old) end,
    OnAdjacentTo = function(self, adjacentUnit, triggerUnit) end,
    OnNotAdjacentTo = function(self, adjacentUnit) end,
    OnConsumptionActive = function(self) end,
    OnConsumptionInActive = function(self) end,
    OnProductionActive = function(self) end,
    OnProductionInActive = function(self) end,
    OnMotionHorzEventChange = function( self, new, old )
        
        
        local bp = self:GetBlueprint()
        if table.find(bp.Categories,'MOBILE') and 
           table.find(bp.Categories,'LAND') then
           LOG("motion", new, old,bp.Intel.moveVisionRadius,bp.Intel.VisionRadius)
          
          for i = 1, unit:GetWeaponCount() do
                local wep = unit:GetWeapon(i)
                local wepbp = wep:GetBlueprint()
                if ( old == 'Stopped' ) and epbp.moveRateOfFire then
                  wep:ChangeRateOfFire( wepbp.moveRateOfFire )
                elseif ( new == 'Stopped' ) and wepbp.RateOfFire then
                  wep:ChangeRateOfFire( wepbp.RateOfFire )
                end
           end
           
          
           if ( old == 'Stopped' ) and bp.Intel.moveVisionRadius then
                  self:SetIntelRadius( 'Vision',bp.Intel.moveVisionRadius )
           elseif ( new == 'Stopped' ) and bp.Intel.VisionRadius then
                  self:SetIntelRadius( 'Vision',bp.Intel.VisionRadius )
           end
           
        end 
      
     end,
    
    # Core unit methods
    ForkThread = function(self, fn, ...)
        if fn then
            local thread = ForkThread(fn, self, unpack(arg))
            self.Trash:Add(thread)
            return thread
        else
            return nil
        end
    end,
}
