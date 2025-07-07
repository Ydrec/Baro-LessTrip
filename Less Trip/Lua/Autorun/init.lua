if SERVER then return end


local defaultconfig = {
    affliction_overlay = 0.5,
    affliction_distort = 0.5,
    affliction_blur = 0.5,
    affliction_grain = 0.5,
    affliction_chromaticaberration = 0.5,
    affliction_radialdistort = 0.5,
    affliction_effectfluctuationfrequency = 1,
    character_distort = 1,
    character_radialdistort = 1,
    character_blur = 1,
    character_grain = 1,
    character_chromaticaberration = 1,
}


local configDirectoryPath = Game.SaveFolder .. "/ModConfigs"
local configFilePath = configDirectoryPath .. "/lesstrip.json"

if not File.Exists(configFilePath) then
    File.Write(configFilePath, json.serialize(defaultconfig))
end

local config = json.parse(File.Read(configFilePath))

local function SaveConfig()
    File.Write(configFilePath, json.serialize(config))
end


LuaUserData.RegisterType('Barotrauma.AfflictionPrefab+Effect') 
LuaUserData.MakePropertyAccessible(Descriptors['Barotrauma.AfflictionPrefab+Effect'], 'MaxAfflictionOverlayAlphaMultiplier')
LuaUserData.MakePropertyAccessible(Descriptors['Barotrauma.AfflictionPrefab+Effect'], 'MinAfflictionOverlayAlphaMultiplier')

LuaUserData.MakePropertyAccessible(Descriptors['Barotrauma.AfflictionPrefab+Effect'], 'MaxScreenDistort')
LuaUserData.MakePropertyAccessible(Descriptors['Barotrauma.AfflictionPrefab+Effect'], 'MinScreenDistort')

LuaUserData.MakePropertyAccessible(Descriptors['Barotrauma.AfflictionPrefab+Effect'], 'MaxRadialDistort')
LuaUserData.MakePropertyAccessible(Descriptors['Barotrauma.AfflictionPrefab+Effect'], 'MinRadialDistort')

LuaUserData.MakePropertyAccessible(Descriptors['Barotrauma.AfflictionPrefab+Effect'], 'MaxScreenBlur')
LuaUserData.MakePropertyAccessible(Descriptors['Barotrauma.AfflictionPrefab+Effect'], 'MinScreenBlur')

LuaUserData.MakePropertyAccessible(Descriptors['Barotrauma.AfflictionPrefab+Effect'], 'MaxGrainStrength')
LuaUserData.MakePropertyAccessible(Descriptors['Barotrauma.AfflictionPrefab+Effect'], 'MinGrainStrength')

LuaUserData.MakePropertyAccessible(Descriptors['Barotrauma.AfflictionPrefab+Effect'], 'MaxChromaticAberration')
LuaUserData.MakePropertyAccessible(Descriptors['Barotrauma.AfflictionPrefab+Effect'], 'MinChromaticAberration')

LuaUserData.MakePropertyAccessible(Descriptors['Barotrauma.AfflictionPrefab+Effect'], 'ScreenEffectFluctuationFrequency')

LuaUserData.MakeMethodAccessible(Descriptors['Barotrauma.AfflictionPrefab'], 'LoadEffects')



local function Exists(tbl, key)
    for k, v in pairs(tbl) do
        if key == k then
            return v
        end
    end
    return false
end


local handlers = {
    affliction_overlay = {
        func = function(self, mult) --ApplyOverlayMultiplier
            if mult then
                config.affliction_overlay = math.min(math.max(mult, 0), 1)
                SaveConfig()
            end
            for afflictionprefab in AfflictionPrefab.Prefabs  do
                for effect in afflictionprefab.Effects do
                    effect.MaxAfflictionOverlayAlphaMultiplier = effect.MaxAfflictionOverlayAlphaMultiplier * config.affliction_overlay
                    effect.MinAfflictionOverlayAlphaMultiplier = effect.MinAfflictionOverlayAlphaMultiplier * config.affliction_overlay
                end
            end  
        end,
        cleanup = function()
            for afflictionprefab in AfflictionPrefab.Prefabs  do
                afflictionprefab.LoadEffects()
            end
        end,
    },
    affliction_distort = {
        func = function(self, mult) --ApplyDisortMultiplier
            if mult then
                config.affliction_distort = math.min(math.max(mult, 0), 1)
                SaveConfig()
            end
            for afflictionprefab in AfflictionPrefab.Prefabs  do
                for effect in afflictionprefab.Effects do
                    effect.MaxScreenDistort = effect.MaxScreenDistort * config.affliction_distort
                    effect.MinScreenDistort = effect.MinScreenDistort * config.affliction_distort
                end
            end  
        end,
        cleanup = nil, --already handled by affliction_overlay cleanup
    },
    affliction_radialdistort = {
        func = function(self, mult)
            if mult then
                config.affliction_radialdistort = math.min(math.max(mult, 0), 1)
                SaveConfig()
            end
            for afflictionprefab in AfflictionPrefab.Prefabs  do
                for effect in afflictionprefab.Effects do
                    effect.MaxRadialDistort = effect.MaxRadialDistort * config.affliction_radialdistort
                    effect.MinRadialDistort = effect.MinRadialDistort * config.affliction_radialdistort
                end
            end  
        end,
        cleanup = nil, --already handled by affliction_overlay cleanup
    },
    affliction_blur = {
        func = function(self, mult)
            if mult then
                config.affliction_blur = math.min(math.max(mult, 0), 1)
                SaveConfig()
            end
            for afflictionprefab in AfflictionPrefab.Prefabs  do
                for effect in afflictionprefab.Effects do
                    effect.MaxScreenBlur = effect.MaxScreenBlur * config.affliction_blur
                    effect.MinScreenBlur = effect.MinScreenBlur * config.affliction_blur
                end
            end  
        end,
        cleanup = nil, --already handled by affliction_overlay cleanup
    },
    affliction_grain = {
        func = function(self, mult)
            if mult then
                config.affliction_grain = math.min(math.max(mult, 0), 1)
                SaveConfig()
            end
            for afflictionprefab in AfflictionPrefab.Prefabs  do
                for effect in afflictionprefab.Effects do
                    effect.MaxGrainStrength = effect.MaxGrainStrength * config.affliction_grain
                    effect.MinGrainStrength = effect.MinGrainStrength * config.affliction_grain
                end
            end  
        end,
        cleanup = nil, --already handled by affliction_overlay cleanup
    },
    affliction_chromaticaberration = {
        func = function(self, mult)
            if mult then
                config.affliction_chromaticaberration = math.min(math.max(mult, 0), 1)
                SaveConfig()
            end
            for afflictionprefab in AfflictionPrefab.Prefabs  do
                for effect in afflictionprefab.Effects do
                    effect.MaxChromaticAberration = effect.MaxChromaticAberration * config.affliction_chromaticaberration
                    effect.MinChromaticAberration = effect.MinChromaticAberration * config.affliction_chromaticaberration
                end
            end  
        end,
        cleanup = nil, --already handled by affliction_overlay cleanup
    },
    affliction_effectfluctuationfrequency = {
        func = function(self, mult)
            if mult then
                config.affliction_effectfluctuationfrequency = math.min(math.max(mult, 0), 1)
                SaveConfig()
            end
            for afflictionprefab in AfflictionPrefab.Prefabs  do
                for effect in afflictionprefab.Effects do
                    effect.ScreenEffectFluctuationFrequency = effect.ScreenEffectFluctuationFrequency * config.affliction_effectfluctuationfrequency
                end
            end  
        end,
        cleanup = nil, --already handled by affliction_overlay cleanup
    },
    character_distort = {
        func = function(self, mult)
            if mult then
                config.character_distort = math.min(math.max(mult, 0), 1)
                SaveConfig()
            end
            if not self.active and config.character_distort ~= 1 then
                self.active = true
                Hook.Patch('LessTrip_distort', 'Barotrauma.Character', 'get_DistortStrength', function(instance, ptable) 
                    return ptable.ReturnValue * config.character_distort
                end, Hook.HookMethodType.After)
            elseif self.active and config.character_distort == 1 then
                self.active = false
                Hook.RemovePatch('LessTrip_distort', 'Barotrauma.Character', 'get_DistortStrength', Hook.HookMethodType.After)
            end
        end,
        cleanup = nil, --Lua patches are not persistent, dont need to clean
        active = false,
    },
    character_radialdistort = {
        func = function(self, mult)
            if mult then
                config.character_radialdistort = math.min(math.max(mult, 0), 1)
                SaveConfig()
            end
            if not self.active and config.character_radialdistort ~= 1 then
                self.active = true
                Hook.Patch('LessTrip_radialdistortdistort', 'Barotrauma.Character', 'get_RadialDistortStrength', function(instance, ptable) 
                    return ptable.ReturnValue * config.character_radialdistort
                end, Hook.HookMethodType.After)
            elseif self.active and config.character_radialdistort == 1 then
                self.active = false
                Hook.RemovePatch('LessTrip_radialdistort', 'Barotrauma.Character', 'get_RadialDistortStrength', Hook.HookMethodType.After)
            end
        end,
        cleanup = nil, --Lua patches are not persistent, dont need to clean
        active = false,
    },
    character_blur = {
        func = function(self, mult)
            if mult then
                config.character_blur = math.min(math.max(mult, 0), 1)
                SaveConfig()
            end
            if not self.active and config.character_blur ~= 1 then
                self.active = true
                Hook.Patch('LessTrip_blur', 'Barotrauma.Character', 'get_BlurStrength', function(instance, ptable) 
                    return ptable.ReturnValue * config.character_blur
                end, Hook.HookMethodType.After)
            elseif self.active  and config.character_blur == 1 then
                self.active = false
                Hook.RemovePatch('LessTrip__blur', 'Barotrauma.Character', 'get_BlurStrength', Hook.HookMethodType.After)
            end
        end,
        cleanup = nil, --Lua patches are not persistent, dont need to clean
        active = false,
    },
    character_grain = {
        func = function(self, mult)
            if mult then
                config.character_grain = math.min(math.max(mult, 0), 1)
                SaveConfig()
            end
            if not self.active and config.character_grain ~= 1 then
                self.active = true
                Hook.Patch('LessTrip_grain', 'Barotrauma.Character', 'get_GrainStrength', function(instance, ptable) 
                    return ptable.ReturnValue * config.character_grain
                end, Hook.HookMethodType.After)
            elseif self.active and config.character_grain == 1 then
                self.active = false
                Hook.RemovePatch('LessTrip_grain', 'Barotrauma.Character', 'get_GrainStrength', Hook.HookMethodType.After)
            end
        end,
        cleanup = nil, --Lua patches are not persistent, dont need to clean
        active = false,
    },
    character_chromaticaberration = {
        func = function(self, mult)
            if mult then
                config.character_chromaticaberration = math.min(math.max(mult, 0), 1)
                SaveConfig()
            end
            if not self.active and config.character_chromaticaberration ~= 1 then
                self.active = true
                Hook.Patch('LessTrip_chromaticaberration', 'Barotrauma.Character', 'get_ChromaticAberrationStrength', function(instance, ptable) 
                    return ptable.ReturnValue * config.character_chromaticaberration
                end, Hook.HookMethodType.After)
            elseif self.active and config.character_chromaticaberration == 1 then
                self.active = false
                Hook.RemovePatch('LessTrip_chromaticaberration', 'Barotrauma.Character', 'get_ChromaticAberrationStrength', Hook.HookMethodType.After)
            end
        end,
        cleanup = nil, --Lua patches are not persistent, dont need to clean
        active = false,
    },
}

local handlerKeys = {}

for k, v in pairs(handlers) do
    table.insert(handlerKeys, k)
end


Game.AddCommand("lesstrip", "lesstrip [effecttype] [0-1]: Multiplies various effects by set values. 1 = no changes; 0 = completely invisible. Is persistent between sessions. character_ effects have small performance cost as always running patches but its necessary to override hardcoded effects: OxygenLow screen distort etc. Setting them to 1 removes patches.",
    function (args)
        if args[1] == nil then 
            for k, v in pairs(config) do
                print(k, " = ", v)
            end
            return
        elseif args[2] and tonumber(args[2]) then
            handler = Exists(handlers, args[1])
            if not handler then print("unknown handler") return end
            handler:func(tonumber(args[2]))
        else
            print("Invalid arguments")
        end
    end,
    --GetValidArguments
    function()
        return {handlerKeys,{"0", "1"}}
    end
)


Hook.Add("stop", "LessTrip_CleanUp", function ()
    for k, handler in pairs(handlers) do
        if handler.cleanup then
            handler.cleanup()
        end
    end
end)

Hook.Add("roundStart", "LessTrip_Apply", function ()
    for k, handler in pairs(handlers) do
        if handler.cleanup then
            handler.cleanup()
        end
    end
    
    for k, handler in pairs(handlers) do
        if handler.func then
            handler:func()
        end
    end
end)

for k, handler in pairs(handlers) do
    if handler.func then
        handler:func()
    end
end

-- Hook.Patch('Barotrauma.AfflictionPrefab', 'LoadEffects', function (instance, ptable) print("######################") end)


