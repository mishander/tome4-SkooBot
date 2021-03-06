local class = require "engine.class"
local Textzone = require "engine.ui.Textzone"
local KeyBind = require "engine.KeyBind"
local GetQuantity = require "engine.dialogs.GetQuantity"

class:bindHook("ToME:run", function(self, data)
	KeyBind:load("toggle-skoobot")
	game.key:addBinds {
		TOGGLE_SKOOBOT = function()
		    local Player = require "mod.class.Player"
		    game.log("#GOLD#SkooBot Toggle requested!")
			Player.skoobot_start()
		end,
		DISABLE_SKOOBOT = function()
		    local Player = require "mod.class.Player"
			if(Player.ai_active) then
				game.log("#GOLD#SkooBot Disable requested!")
				Player.ai_active = false
			end
		end,
		SKOOBOT_RUNONCE = function()
		    local Player = require "mod.class.Player"
		    game.log("#GOLD#SkooBot Single Run requested!")
			Player.skoobot_runonce()
		end,
		ASK_SKOOBOT = function()
		    local Player = require "mod.class.Player"
		    game.log("#GOLD#SkooBot Query requested!")
			Player.skoobot_query()
		end,
		SKOOBOT_MENU = function()
			local d = require("mod.dialogs.SkoobotMenu").new()
		    game.log("#GOLD#SkooBot Menu requested!")
			game:registerDialog(d)
		end
	}
end)

dofile("/data-skoobot/settings.lua")
--
-- tab=function
class:bindHook("GameOptions:tabs", function(self, data)
	-- *** This makes sure ALL of my Quality of Life packs are in one tab!
	if not self.skoobot_optioninit then
		self.skoobot_optioninit = true
		--
		data.tab("[SkooBot]", function() self.list = { skoobot_options=true } end)
	end
end)

local addonTitle = [[SkooBot]]
local addonShort = [[skoobot]]
-- list=self.list, kind=kind
class:bindHook("GameOptions:generateList", function(self, data)
	if data.list.skoobot_options then
		local list = data.list
		--
		-- *** Let's put all the "ugly" stuff in here. (:3)
		local function createOption(option, tabTitle, desc, defaultFunct, defaultStatus)
			defaultFunct = defaultFunct or function(item)
				config.settings.tome.SkooBot[option] = not config.settings.tome.SkooBot[option]
				--
				game:saveSettings("tome.SkooBot."..option, ("tome.SkooBot."..option.." = %s\n"):format(tostring(config.settings.tome.SkooBot[option])))
				self.c_list:drawItem(item)
			end
			defaultStatus = defaultStatus or function(item)
				return tostring(config.settings.tome.SkooBot[option] and "enabled" or "disabled")
			end
			
			list[#list+1] = { zone=Textzone.new{width=self.c_desc.w, height=self.c_desc.h,
			text=string.toTString("#GOLD#"..addonTitle.."\n\n#WHITE#"..desc.."#WHITE#")}, name=string.toTString(("#GOLD##{bold}#[%s] %s#WHITE##{normal}#"):format(addonShort, tabTitle)), status=defaultStatus, fct=defaultFunct,}
		end
		local function createNumericalOption(option, tabTitle, desc, defaultFunct, defaultStatus, minVal, maxVal, prompt)
			minVal = minVal or 0
			maxVal = maxVal or 1000000
			defaultFunct = defaultFunct or function(item)
				game:registerDialog(GetQuantity.new(prompt, "From "..minVal.." to"..maxVal, config.settings.tome.SkooBot[option] or minVal, maxVal, function(qty)
					config.settings.tome.SkooBot[option] = qty
					game:saveSettings("tome.SkooBot."..option, ("tome.SkooBot."..option.." = %s\n"):format(tostring(config.settings.tome.SkooBot[option])))
					self.c_list:drawItem(item)
				end))
			end
			defaultStatus = defaultStatus or function(item)
				return tostring(config.settings.tome.SkooBot[option] or "-")
			end
			
			list[#list+1] = { zone=Textzone.new{width=self.c_desc.w, height=self.c_desc.h,
			text=string.toTString("#GOLD#"..addonTitle.."\n\n#WHITE#"..desc.."#WHITE#")}, name=string.toTString(("#GOLD##{bold}#[%s] %s#WHITE##{normal}#"):format(addonShort, tabTitle)), status=defaultStatus, fct=defaultFunct,}
		end
		--
		--
		
		createNumericalOption("LOWHEALTH_RATIO", "Low Health Ratio",
			"Bot pauses when under this life percent. Also will pause when losing half this percent life in a single round.")
		createNumericalOption("IGNORE_DAMAGE_HEALTH_RATIO", "Ignore Damage Health Ratio",
			"Bot will not pause when bot takes damage while exploring and life is higher than this.")
		createNumericalOption("MAX_INDIVIDUAL_POWER", "Max enemy power level",
			"Pauses the bot when an enemy with a power level over this amount is spotted.")
		createNumericalOption("MAX_DIFF_POWER", "Maximum Individual Enemy Power",
			"Pauses the bot when an enemy with a power level this much higher than yours is spotted.")
		createNumericalOption("MAX_COMBINED_POWER", "Maximum Combined Enemy Power",
			"Pauses the bot when the combined power level of visible enemies is over this amount.")
		createNumericalOption("MAX_ENEMY_COUNT", "Maximum Enemy Count",
			"Pauses the bot when this many enemies is spotted.")
		createNumericalOption("ACTION_DELAY", "Skoobot Action Delay",
			"Bot will wait this many seconds between each action. THIS IS CURRENTLY A BIT BUGGY AND THE BOT WILL ACT WHEN YOU PRESS BUTTONS OR MOVE YOUR MOUSE IN ADDITION TO AUTOMATICALLY WITH THIS DELAY")
		createNumericalOption("NORMAL_POWER_RATIO", "Coefficient to apply to common enemies power ratio",
			"When calculating power ratio bot will multiply power ratio of common enemies by that coefficient.")
		createNumericalOption("ELITES_POWER_RATIO", "Coefficient to apply to elites/rares/uniques enemies power ratio",
			"When calculating power ratio bot will multiply power ratio of elites/rares/uniques enemies by that coefficient.")	
		createNumericalOption("BOSS_POWER_RATIO", "Coefficient to apply to boss/elite boss/go enemies power ratio",
			"When calculating power ratio bot will multiply power ratio of elites/rares/uniques enemies by that coefficient.")			
	end
end)