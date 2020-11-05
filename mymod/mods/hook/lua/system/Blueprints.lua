do
	local oldModBP = ModBlueprints
	LOG('GO MOD ')
	function ModBlueprints(all_bps)
		oldModBP(all_bps)
		
		local landSpeed = 1.35  --Land units speed
		local landSpeedT2 = 1.55  --Land units speed
		--local vision    =   --Line of sight, radar, and omni range
		
    local visionRadius = 0.6
    local scoutVisionRadius = 1.3
    local weaponRadius = 1.5	
    local shotVel = 1.3 
		
		for index,unit in all_bps.Unit do
			if unit.Categories then
    
------------------------------------------------------------------------------------------------------------------------------------
				if table.find(unit.Categories,'MOBILE') and 
				   table.find(unit.Categories,'LAND') then
-------------------------------------[Amphibious navy]------------------------------------------------------------------------------
					if table.find(unit.Categories,'TECH1') or table.find(unit.Categories,'TECH3') then
               if unit.Physics.MaxSpeed  then
                unit.Physics.MaxSpeed = unit.Physics.MaxSpeed * landSpeed 
               end
               if unit.Display.AnimationWalkRate then
                 unit.Display.AnimationWalkRate = unit.Display.AnimationWalkRate * landSpeed 
               end
					elseif table.find(unit.Categories,'TECH2') then 
						
	             if unit.Physics.MaxSpeed  then
                unit.Physics.MaxSpeed = unit.Physics.MaxSpeed * landSpeedT2 
               end
	             if unit.Display.AnimationWalkRate then
	               unit.Display.AnimationWalkRate = unit.Display.AnimationWalkRate * landSpeedT2 
               end
	        
					end
					
          if table.find(unit.Categories,'TECH1') or
             table.find(unit.Categories,'TECH2') or
             table.find(unit.Categories,'TECH3') then
					   if unit.Weapon then 
                 for index,wep in unit.Weapon do
                        if wep.RateOfFire then
                          wep.RateOfFire = 10
                        end
                --  if wep.Label != 'DeathWeapon' then
                        if wep.MaxRadius then 
                          wep.MaxRadius = wep.MaxRadius * weaponRadius 
                          if table.find(unit.Categories,'ARTILLERY') then
                            if wep.MuzzleVelocity then 
                              wep.MuzzleVelocity = wep.MuzzleVelocity *shotVel --weaponRadius 
                            end
                            --[[
                            if wep.MuzzleVelocityReduceDistance then 
                              wep.MuzzleVelocityReduceDistance = wep.MuzzleVelocityReduceDistance * weaponRadius 
                            end
                            ]]--
                            if wep.TurretPitchRange < 60 then
                               wep.TurretPitchRange = 60
                            end
                          end
                          
                        end
                 -- end
                 end
              end
              if unit.Intel.VisionRadius   then
              
                if table.find(unit.Categories,'SCOUT') then
                     unit.Intel.VisionRadius = math.ceil(unit.Intel.VisionRadius * scoutVisionRadius)
                else
                     unit.Intel.VisionRadius = math.ceil(unit.Intel.VisionRadius * visionRadius)  
                end
              end
              
            end
					
				end

			end
		end
	end
end