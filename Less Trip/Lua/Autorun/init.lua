if SERVER then return end

local Path = ...

if not File.Exists(Path .. "/config.json") then
    File.Write(Path .. "/config.json", json.serialize({multiplier = 0.5}))
end

local config = json.parse(File.Read(Path .. "/config.json"))
--print(config.multiplier)

LuaUserData.RegisterType('Barotrauma.AfflictionPrefab+Effect') 
LuaUserData.MakePropertyAccessible(Descriptors['Barotrauma.AfflictionPrefab+Effect'], 'MaxAfflictionOverlayAlphaMultiplier')
LuaUserData.MakePropertyAccessible(Descriptors['Barotrauma.AfflictionPrefab+Effect'], 'MinAfflictionOverlayAlphaMultiplier')

LuaUserData.MakeMethodAccessible(Descriptors['Barotrauma.AfflictionPrefab'], 'LoadEffects')

local function ApplyOverlayMultiplier(mult)
    local mult = mult or  config.multiplier
    for afflictionprefab in AfflictionPrefab.Prefabs  do
        for effect in afflictionprefab.Effects do
            --print(mult)
            effect.MaxAfflictionOverlayAlphaMultiplier = effect.MaxAfflictionOverlayAlphaMultiplier * mult
            effect.MinAfflictionOverlayAlphaMultiplier = effect.MinAfflictionOverlayAlphaMultiplier * mult
        end
    end
end

local function CleanUp()
    for afflictionprefab in AfflictionPrefab.Prefabs  do
        afflictionprefab.LoadEffects()
    end
end


Game.AddCommand("lesstrip", "Multiplies opacity on all affliction overlays by this multiplier. 1 = no changes; 0 = completely invisible. Is persistent between sessions", function (args)
    if args[1] == nil then return end
    local mult = math.max(tonumber(args[1]),0)
    config.multiplier = mult
    File.Write(Path .. "/config.json", json.serialize(config))
    CleanUp()
    ApplyOverlayMultiplier()
end)


Hook.Add("stop", "LessTrip_CleanUp", function ()
    CleanUp()
end)


Hook.Add("roundStart", "LessTrip_Apply", function ()
    --print("@@@@@@@@@@@@@@@@@@@")
    ApplyOverlayMultiplier()
end)

-- Hook.Patch('Barotrauma.AfflictionPrefab', 'LoadEffects', function (instance, ptable) print("######################") end)


