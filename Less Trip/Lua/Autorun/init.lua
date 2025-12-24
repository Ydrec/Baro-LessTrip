if SERVER then return end

local configversion = 2

local defaultconfig = {
    version = configversion,
    data = {
        affliction_overlay = 0.5,
        -- affliction_distort = 0.5,
        -- affliction_blur = 0.5,
        -- affliction_grain = 0.5,
        -- affliction_chromaticaberration = 0.5,
        -- affliction_radialdistort = 0.5,
        affliction_effectfluctuationfrequency = 1,
        distort = 0.5,
        radialdistort = 0.5,
        blur = 0.5,
        grain = 0.5,
        chromaticaberration = 0.5,
        screenshake = 0.5,
        collapseeffect = 1,
        rotation = 0.5,
    }
}


local configDirectoryPath = Game.SaveFolder .. "/ModConfigs"
local configFilePath = configDirectoryPath .. "/lesstrip.json"

if not File.Exists(configFilePath) then
    File.Write(configFilePath, json.serialize(defaultconfig))
end

local config = json.parse(File.Read(configFilePath))


local function CheckConfigVersion()
    if not config.version then
        local tmpconfig = {}
        tmpconfig.data = {}
        tmpconfig.version = 2
        tmpconfig.data.affliction_overlay = config.affliction_overlay
        tmpconfig.data.affliction_effectfluctuationfrequency = config.affliction_effectfluctuationfrequency

        tmpconfig.data.distort = config.character_distort
        tmpconfig.data.radialdistort = config.character_radialdistort
        tmpconfig.data.blur = config.character_blur
        tmpconfig.data.grain = config.character_grain
        tmpconfig.data.chromaticaberration = config.character_chromaticaberration
        tmpconfig.data.screenshake = config.screenshake
        config = tmpconfig
    end
end


local function CheckConfigHasAllKeys(config, keys)
    for k in keys do
        if not config.data[k] then
            config.data[k] = defaultconfig.data[k] or 1
        end
    end
end

local function SaveConfig()
    File.Write(configFilePath, json.serialize(config))
end

LuaUserData.RegisterType('Barotrauma.MathUtils')
local MathUtils = LuaUserData.CreateStatic('Barotrauma.MathUtils')

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

LuaUserData.MakePropertyAccessible(Descriptors['Barotrauma.Character'], 'ChromaticAberrationStrength')

LuaUserData.MakePropertyAccessible(Descriptors['Barotrauma.Camera'], 'ShakePosition')

LuaUserData.MakeFieldAccessible(Descriptors['Barotrauma.Camera'], 'rotation')

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
            mult = math.clamp(mult or config.data.distort, 0, 1)
            for afflictionprefab in AfflictionPrefab.Prefabs  do
                for effect in afflictionprefab.Effects do
                    effect.MaxAfflictionOverlayAlphaMultiplier = effect.MaxAfflictionOverlayAlphaMultiplier * mult
                    effect.MinAfflictionOverlayAlphaMultiplier = effect.MinAfflictionOverlayAlphaMultiplier * mult
                end
            end  
        end,
        cleanup = function()
            for afflictionprefab in AfflictionPrefab.Prefabs  do
                ResetAfflictionPrefabEffects(afflictionprefab)
            end
        end,
    },
    -- affliction_distort = {
    --     func = function(self, mult) --ApplyDisortMultiplier
    --         if mult then
    --             config.affliction_distort = math.min(math.max(mult, 0), 1)
    --             SaveConfig()
    --         end
    --         for afflictionprefab in AfflictionPrefab.Prefabs  do
    --             for effect in afflictionprefab.Effects do
    --                 effect.MaxScreenDistort = effect.MaxScreenDistort * config.affliction_distort
    --                 effect.MinScreenDistort = effect.MinScreenDistort * config.affliction_distort
    --             end
    --         end  
    --     end,
    --     cleanup = nil, --already handled by affliction_overlay cleanup
    -- },
    -- affliction_radialdistort = {
    --     func = function(self, mult)
    --         if mult then
    --             config.affliction_radialdistort = math.min(math.max(mult, 0), 1)
    --             SaveConfig()
    --         end
    --         for afflictionprefab in AfflictionPrefab.Prefabs  do
    --             for effect in afflictionprefab.Effects do
    --                 effect.MaxRadialDistort = effect.MaxRadialDistort * config.affliction_radialdistort
    --                 effect.MinRadialDistort = effect.MinRadialDistort * config.affliction_radialdistort
    --             end
    --         end  
    --     end,
    --     cleanup = nil, --already handled by affliction_overlay cleanup
    -- },
    -- affliction_blur = {
    --     func = function(self, mult)
    --         if mult then
    --             config.affliction_blur = math.min(math.max(mult, 0), 1)
    --             SaveConfig()
    --         end
    --         for afflictionprefab in AfflictionPrefab.Prefabs  do
    --             for effect in afflictionprefab.Effects do
    --                 effect.MaxScreenBlur = effect.MaxScreenBlur * config.affliction_blur
    --                 effect.MinScreenBlur = effect.MinScreenBlur * config.affliction_blur
    --             end
    --         end  
    --     end,
    --     cleanup = nil, --already handled by affliction_overlay cleanup
    -- },
    -- affliction_grain = {
    --     func = function(self, mult)
    --         if mult then
    --             config.affliction_grain = math.min(math.max(mult, 0), 1)
    --             SaveConfig()
    --         end
    --         for afflictionprefab in AfflictionPrefab.Prefabs  do
    --             for effect in afflictionprefab.Effects do
    --                 effect.MaxGrainStrength = effect.MaxGrainStrength * config.affliction_grain
    --                 effect.MinGrainStrength = effect.MinGrainStrength * config.affliction_grain
    --             end
    --         end  
    --     end,
    --     cleanup = nil, --already handled by affliction_overlay cleanup
    -- },
    -- affliction_chromaticaberration = {
    --     func = function(self, mult)
    --         if mult then
    --             config.affliction_chromaticaberration = math.min(math.max(mult, 0), 1)
    --             SaveConfig()
    --         end
    --         for afflictionprefab in AfflictionPrefab.Prefabs  do
    --             for effect in afflictionprefab.Effects do
    --                 effect.MaxChromaticAberration = effect.MaxChromaticAberration * config.affliction_chromaticaberration
    --                 effect.MinChromaticAberration = effect.MinChromaticAberration * config.affliction_chromaticaberration
    --             end
    --         end  
    --     end,
    --     cleanup = nil, --already handled by affliction_overlay cleanup
    -- },
    affliction_effectfluctuationfrequency = {
        func = function(self, mult)
            mult = math.clamp(mult or config.data.distort, 0, 1)
            for afflictionprefab in AfflictionPrefab.Prefabs  do
                for effect in afflictionprefab.Effects do
                    effect.ScreenEffectFluctuationFrequency = effect.ScreenEffectFluctuationFrequency * mult
                end
            end  
        end,
        cleanup = nil, --already handled by affliction_overlay cleanup
    },
    distort = {
        func = function(self, mult)
            --multiplier gets baked into patch closure to minimize lookup time but have to rehook method to update it
            mult = math.clamp(mult or config.data.distort, 0, 1)
            Hook.RemovePatch('LessTrip_distort', 'Barotrauma.Character', 'get_DistortStrength', Hook.HookMethodType.After)
            if mult ~= 1 then
                Hook.Patch('LessTrip_distort', 'Barotrauma.Character', 'get_DistortStrength', function(instance, ptable) 
                    return ptable.ReturnValue * mult
                end, Hook.HookMethodType.After)
            end
        end,
        cleanup = nil, --Lua patches are not persistent, dont need to clean
    },
    radialdistort = {
        func = function(self, mult)
            mult = math.clamp(mult or config.data.radialdistort, 0, 1)
            Hook.RemovePatch('LessTrip_radialdistort', 'Barotrauma.Character', 'get_RadialDistortStrength', Hook.HookMethodType.After)
            if mult ~= 1 then
                Hook.Patch('LessTrip_radialdistort', 'Barotrauma.Character', 'get_RadialDistortStrength', function(instance, ptable) 
                    return ptable.ReturnValue * mult
                end, Hook.HookMethodType.After)
            end
        end,
        cleanup = nil, --Lua patches are not persistent, dont need to clean
    },
    blur = {
        func = function(self, mult)
            mult = math.clamp(mult or config.data.blur, 0, 1)
            Hook.RemovePatch('LessTrip_blur', 'Barotrauma.Character', 'get_BlurStrength', Hook.HookMethodType.After)
            if mult ~= 1 then
                Hook.Patch('LessTrip_blur', 'Barotrauma.Character', 'get_BlurStrength', function(instance, ptable) 
                    return ptable.ReturnValue * mult
                end, Hook.HookMethodType.After)                
            end
        end,
        cleanup = nil, --Lua patches are not persistent, dont need to clean
    },
    grain = {
        func = function(self, mult)
            mult = math.clamp(mult or config.data.grain, 0, 1)
            Hook.RemovePatch('LessTrip_grain', 'Barotrauma.Character', 'get_GrainStrength', Hook.HookMethodType.After)
            if mult ~= 1 then
                Hook.Patch('LessTrip_grain', 'Barotrauma.Character', 'get_GrainStrength', function(instance, ptable) 
                    return ptable.ReturnValue * mult
                end, Hook.HookMethodType.After)
            end
        end,
        cleanup = nil, --Lua patches are not persistent, dont need to clean
    },
    chromaticaberration = {
        func = function(self, mult)
            mult = math.clamp(mult or config.data.chromaticaberration, 0, 1)
            Hook.RemovePatch('LessTrip_chromaticaberration_char', 'Barotrauma.Character', 'get_ChromaticAberrationStrength', Hook.HookMethodType.After)
            Hook.RemovePatch('LessTrip_chromaticaberration_level', 'Barotrauma.LevelRenderer', 'get_ChromaticAberrationStrength', Hook.HookMethodType.After)
            if  mult ~= 1 then
                self.active = true
                Hook.Patch('LessTrip_chromaticaberration_char', 'Barotrauma.Character', 'get_ChromaticAberrationStrength', function(instance, ptable) 
                    return ptable.ReturnValue * mult
                end, Hook.HookMethodType.After)
                Hook.Patch('LessTrip_chromaticaberration_level', 'Barotrauma.LevelRenderer', 'get_ChromaticAberrationStrength', function(instance, ptable) 
                    return ptable.ReturnValue * mult
                end, Hook.HookMethodType.After)
            end
        end,
        cleanup = nil, --Lua patches are not persistent, dont need to clean
    },
    screenshake = {
        func = function(self, mult))
            mult = math.clamp(mult or config.data.screenshake, 0, 1)
            Hook.RemovePatch('LessTrip_screenshake', 'Barotrauma.Camera', 'get_ShakePosition', Hook.HookMethodType.After)
            if mult ~= 1 then
                Hook.Patch('LessTrip_screenshake', 'Barotrauma.Camera', 'get_ShakePosition', function(instance, ptable)
                    return ptable.ReturnValue * mult
                end, Hook.HookMethodType.After)
            end
        end,
        cleanup = nil, --Lua patches are not persistent, dont need to clean
    },
    collapseeffect = {
        func = function(self, mult))
            mult = math.clamp(mult or config.data.collapseeffect, 0, 1)
            Hook.RemovePatch('LessTrip_collapseeffect', 'Barotrauma.Character', 'set_CollapseEffectStrength', Hook.HookMethodType.After)
            if mult ~= 1 then
                Hook.Patch('LessTrip_collapseeffect', 'Barotrauma.Character', 'set_CollapseEffectStrength', function(instance, ptable)
                    Level.Loaded.Renderer.CollapseEffectStrength = 0
                end, Hook.HookMethodType.After)
            end
        end,
        cleanup = nil, --Lua patches are not persistent, dont need to clean
    },
    rotation = {
        func = function(self, mult))
            mult = math.clamp(mult or config.data.rotation, 0, 1)
            Hook.RemovePatch('LessTrip_rotation', 'Barotrauma.Camera', 'set_Rotation', Hook.HookMethodType.Before)
            if mult ~= 1 then
                Hook.Patch('LessTrip_rotation', 'Barotrauma.Camera', 'set_Rotation', function(instance, ptable)
                    if MathUtils.IsValid(ptable["value"]) then
                        instance.rotation = ptable["value"] * mult
                    end
                    ptable.PreventExecution = true
                end, Hook.HookMethodType.Before)
            end
        end,
        cleanup = nil, --Lua patches are not persistent, dont need to clean
    },
}

local handlerKeys = {}

for k, v in pairs(handlers) do
    table.insert(handlerKeys, k)
end

CheckConfigVersion()

CheckConfigHasAllKeys(config, handlerKeys)

Game.AddCommand("lesstrip", "lesstrip [effecttype] [0-1]: Multiplies various effects by set values. 1 = no changes; 0 = completely invisible. Is persistent between sessions. character_ effects have small performance cost as always running patches but its necessary to override hardcoded effects: OxygenLow screen distort etc. Setting them to 1 removes patches.",
    function (args)
        if args[1] == nil then
            print("current values:")
            for k, v in pairs(config.data) do
                local note = ""
                if k == "collapseeffect" then
                    note = "   Note: Can only be On/Off, granular control would require rewriting rendering for it and lua would burn fps"
                end
                print(k, " = ", v, note)
            end
            return
        elseif args[2] and tonumber(args[2]) then
            handler = Exists(handlers, args[1])
            if not handler then print("unknown handler") return end
            if args[1] == "collapseeffect" then
                args[2] = tonumber(args[2]) < 1 and 0 or 1
            end
            config.data[args[1]] = math.clamp(tonumber(args[2]), 0, 1)
            handler:func()
            SaveConfig()
        else
            print("Invalid arguments")
        end
    end,
    --GetValidArguments
    function()
        return {handlerKeys,{"0", "1"}}
    end
)

Game.AddCommand("lesstrip_debug", "lesstrip [0-2]: 0 = Use config values, 1 = Hide all effects, 2 = Show all effects",
    function (args)
        if args[1] == nil then
            print("0 = Use config values, 1 = Hide all effects, 2 = Show all effects")
            return
        elseif args[1] == "0" then
            for k, handler in pairs(handlers) do
                if handler.func then
                    handler:func()
                end
            end
        elseif args[1] == "1" then
            for key, handler in pairs(handlers) do
                handler:func(0)
            end
        elseif args[1] == "2" then
            for key, handler in pairs(handlers) do
                handler:func(1)
            end
        end
    end,
    --GetValidArguments
    function()
        return {{"0", "1", "2"}}
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


