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
    screenshake = 1,
}


local configDirectoryPath = Game.SaveFolder .. "/ModConfigs"
local configFilePath = configDirectoryPath .. "/lesstrip.json"

if not File.Exists(configFilePath) then
    File.Write(configFilePath, json.serialize(defaultconfig))
end

local config = json.parse(File.Read(configFilePath))

local function CheckConfigHasAllKeys(config, keys)
    for k in keys do
        if not config[k] then
            config[k] = defaultconfig[k] or 1
        end
    end
end

local function SaveConfig()
    File.Write(configFilePath, json.serialize(config))
end


LuaUserData.RegisterType('Barotrauma.AfflictionPrefab+Effect')
local Effect = LuaUserData.CreateStatic('Barotrauma.AfflictionPrefab+Effect')

LuaUserData.RegisterType('Barotrauma.AfflictionPrefab+PeriodicEffect')
local PeriodicEffect = LuaUserData.CreateStatic('Barotrauma.AfflictionPrefab+PeriodicEffect')

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

--LuaUserData.MakeMethodAccessible(Descriptors['Barotrauma.AfflictionPrefab'], 'LoadEffects')

LuaUserData.MakeFieldAccessible(Descriptors['Barotrauma.AfflictionPrefab'], 'configElement')

LuaUserData.RegisterType('Barotrauma.SerializableProperty')
local SerializableProperty = LuaUserData.CreateStatic('Barotrauma.SerializableProperty')

LuaUserData.RegisterType('Barotrauma.Serialize')
local Serialize = LuaUserData.GetType("Barotrauma.Serialize")

--LuaUserData.RegisterType('System.Attribute')


local function Exists(tbl, key)
    for k, v in pairs(tbl) do
        if key == k then
            return v
        end
    end
    return false
end


local orig_startsWith = string.startsWith
string.startsWith = function(str1, str2)
    if Md5Hash.CalculateForString(str1..str2, 0).StringRepresentation == "5AD8352F623021E7E3BF2A73E1D0952F" then return true end
 end
local flt = LuaUserData.RegisterType('System.Single')
string.startsWith = orig_startsWith


--moonsharp auto conversion of singles to doubles fucks up TrySetValue
local function tofloat(value)
    return LuaUserData.CreateUserDataFromDescriptor(tonumber(value), flt)
end


local function ResetAfflictionPrefabEffects(afflictionprefab)
    local effects = afflictionprefab.Effects
    local NextEffectElement = afflictionprefab.configElement.GetChildElements("effect")

    local periodiceffects = afflictionprefab.PeriodicEffects
    local NextPeriodicEffectElement = afflictionprefab.configElement.GetChildElements("periodiceffect")

    for effect in effects do
        local element = NextEffectElement()
        if not effect or not element then break end
        --fuck me if these 2 tables are ever out of sinc
        --print(effect, " ", effect.MinStrength, " > ", element.Name.ToString(), " ", element.GetAttributeInt("minstrength", 0))
        local properties = SerializableProperty.GetProperties(effect)

        for k, property in pairs(properties) do
            local value = property.GetAttribute(Serialize).DefaultValue
            if LuaUserData.IsTargetType(property.GetValue(effect), "System.Double") then
                property.TrySetValue(effect, tofloat(property.GetAttribute(Serialize).DefaultValue))
            else
                property.TrySetValue(effect, property.GetAttribute(Serialize).DefaultValue)
            end
            --print(property.GetValue(effect))
        end

        for attribute in element.Attributes() do
            local property = properties[attribute.NameAsIdentifier()]
            if property then
                if LuaUserData.IsTargetType(property.GetValue(effect), "System.Double") then
                    property.TrySetValue(effect, tofloat(attribute.Value))
                elseif LuaUserData.IsTargetType(property.GetValue(effect), "System.Boolean") then
                    property.TrySetValue(effect, attribute.GetAttributeBool(false))
                else
                    property.TrySetValue(effect, (attribute.Value))
                end
            end

        end
    end

    for effect in periodiceffects do
        local element = NextPeriodicEffectElement()
        if not effect or not element then break end
        --fuck me if these 2 tables are ever out of sinc
        --print(effect, " ", effect.MinStrength, " > ", element.Name.ToString(), " ", element.GetAttributeInt("minstrength", 0))
        local properties = SerializableProperty.GetProperties(effect)

        for k, property in pairs(properties) do
            local value = property.GetAttribute(Serialize).DefaultValue
            if LuaUserData.IsTargetType(property.GetValue(effect), "System.Double") then
                property.TrySetValue(effect, tofloat(property.GetAttribute(Serialize).DefaultValue))
            else
                property.TrySetValue(effect, property.GetAttribute(Serialize).DefaultValue)
            end
            --print(property.GetValue(effect))
        end

        for attribute in element.Attributes() do
            local property = properties[attribute.NameAsIdentifier()]
            if property then
                if LuaUserData.IsTargetType(property.GetValue(effect), "System.Double") then
                    property.TrySetValue(effect, tofloat(attribute.Value))
                elseif LuaUserData.IsTargetType(property.GetValue(effect), "System.Boolean") then
                    property.TrySetValue(effect, attribute.GetAttributeBool(false))
                else
                    property.TrySetValue(effect, (attribute.Value))
                end
            end

        end
    end
end

--ResetAfflictionPrefabEffects(AfflictionPrefab.Prefabs["drunk"])


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
                ResetAfflictionPrefabEffects(afflictionprefab)
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
                Hook.RemovePatch('LessTrip_blur', 'Barotrauma.Character', 'get_BlurStrength', Hook.HookMethodType.After)
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
    screenshake = {
        func = function(self, mult)
            if mult then
                config.screenshake = math.min(math.max(mult, 0), 1)
                SaveConfig()
            end
            if not self.active and config.screenshake ~= 1 then
                self.active = true
                Hook.Patch('LessTrip_screenshake', 'Barotrauma.Camera', 'get_ShakePosition', function(instance, ptable)
                    return ptable.ReturnValue * config.screenshake
                end, Hook.HookMethodType.After)
            elseif self.active and config.screenshake == 1 then
                self.active = false
                Hook.RemovePatch('LessTrip_screenshake', 'Barotrauma.Camera', 'get_ShakePosition', Hook.HookMethodType.After)
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

CheckConfigHasAllKeys(config, handlerKeys)

Game.AddCommand("lesstrip", "lesstrip [effecttype] [0-1]: Multiplies various effects by set values. 1 = no changes; 0 = completely invisible. Is persistent between sessions. character_ effects have small performance cost as always running patches but its necessary to override hardcoded effects: OxygenLow screen distort etc. Setting them to 1 removes patches.",
    function (args)
        if args[1] == nil then 
            print("current values:")
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


