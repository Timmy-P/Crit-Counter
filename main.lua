CritCounter = CritCounter or {}
CritCounter.total_crits = 0
CritCounter.total_hits = 0
CritCounter.percentage = 0
CritCounter.color = Color(255, 0, 100, 255) / 255

local can_crit

function CritCounter.Reset()
	CritCounter.total_crits = 0
	CritCounter.percentage = 0
	CritCounter.total_hits = 0
end

function CritCounter.AddCrit()
	CritCounter.total_crits = CritCounter.total_crits + 1
	--CritCounter.AddHit()
end

function CritCounter.AddHit()
	CritCounter.total_hits = CritCounter.total_hits + 1
end

function CritCounter.CalculatePercentage()
	if CritCounter.total_hits == 0 then
		CritCounter.percentage = 0
	else
		CritCounter.percentage = math.floor((CritCounter.total_crits / CritCounter.total_hits) * 100)
	end
end

function CritCounter.SetupHooks() 
	if RequiredScript == "lib/states/missionendstate" then
		Hooks:PostHook(MissionEndState,"at_enter", "get_crit_results", function(self, ...)
			CritCounter.CalculatePercentage()
			managers.chat:_receive_message(managers.chat.GAME, "Crit Counter", "You crit a total of: " .. CritCounter.total_crits .. " out of " .. CritCounter.total_hits .. " hits," .. " for an average of " .. CritCounter.percentage .. "%", CritCounter.color)
			CritCounter.Reset()
		end )
	elseif RequiredScript == "lib/units/enemies/cop/copdamage" then
		Hooks:PostHook(CopDamage, "can_be_critical", "crit_checker", function(self, attack_data)
			can_crit = Hooks:GetReturn() --Returns either a true or false flag, determining the ability to crit.
			if attack_data.variant == "stun" then
				can_crit = false
			end
			if can_crit == false then
				--managers.chat:_receive_message(managers.chat.GAME, "debug1", "You can't crit!", CritCounter.color)
			end
		end )
		Hooks:PostHook(CopDamage, "roll_critical_hit", "crit_counter", function(self, attack_data)
			if can_crit == true then
				CritCounter.AddHit()
				local diditcrit = Hooks:GetReturn()
				--managers.chat:_receive_message(managers.chat.GAME, "debug1", "Hit!", CritCounter.color)
				--managers.chat:_receive_message(managers.chat.GAME, "debug1", "Rollin!", CritCounter.color)
				if diditcrit == true then
					--managers.chat:_receive_message(managers.chat.GAME, "debug1", CritCounter.total_crits .. " crits", CritCounter.color)
					CritCounter.AddCrit()
				end
			end
		end )
	end
end

CritCounter.SetupHooks()