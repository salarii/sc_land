do
	local oldModBP = ModBlueprints
	LOG('GO MOD ')
	function ModBlueprints(all_bps)
		oldModBP(all_bps)
		
		local landSpeed = 1.35  --Land units speed
		local landSpeedT2 = 1.6  --Land units speed
		--local vision    =   --Line of sight, radar, and omni range
		
    local visionRadius = 0.65
    local scoutVisionRadius = 1.1
    local weaponRadius = 1.5	
    local omniRadius = 1.4
    local omniArtyRadius = 1.65
    local shotVel = 1.3 
		local moveFireRateLimit = 0.5
    local moveObserveLimit = 0.8		
		local healthRatio = 0.6
		
		for index,unit in all_bps.Unit do
			if unit.Categories then

				if table.find(unit.Categories,'MOBILE') and 
				   table.find(unit.Categories,'LAND') then


          if table.find(unit.Categories,'TECH1') and unit.Defense.Health then 
            unit.Defense.Health = unit.Defense.Health * healthRatio
            unit.Defense.MaxHealth =  unit.Defense.MaxHealth * healthRatio
          end

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
          if unit.Intel.VisionRadius   then
              
                if table.find(unit.Categories,'SCOUT') then
                     unit.Intel.VisionRadius = math.ceil(unit.Intel.VisionRadius * scoutVisionRadius)
                else
                --FreeIntel = true,
                      unit.Intel.FreeIntel = true 
                
                     if table.find(unit.Categories,'ARTILLERY') then
                      unit.Intel.OmniRadius = math.ceil(unit.Intel.VisionRadius * omniArtyRadius)
                     else
                      unit.Intel.OmniRadius = math.ceil(unit.Intel.VisionRadius * omniRadius)       
                     end
                     
                     unit.Intel.VisionRadius = math.ceil(unit.Intel.VisionRadius * visionRadius)  
                     unit.Intel.moveVisionRadius = math.ceil(unit.Intel.VisionRadius * moveObserveLimit)
                end
          end
          if table.find(unit.Categories,'TECH1') or
             table.find(unit.Categories,'TECH2') or
             table.find(unit.Categories,'TECH3') then
             table.insert(unit.Categories,'OVERLAYOMNI')

					   if unit.Weapon then 
                 for index,wep in unit.Weapon do
                        
                        if wep.RateOfFire then
                          
                          wep.moveRateOfFire =wep.RateOfFire * moveFireRateLimit
                          
                        end

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

                 end
              end

              
            end
					
				end

			end
		end
	end
end