local loaded = false
local data = nil
RegisterNetEvent('nx-core:client:playerData', function(payload)
    data = payload
    if loaded then print(('[NX-Core] %s %s | Efectivo $%s | Banco $%s'):format(data.firstname,data.lastname,data.cash,data.bank)) end
end)
RegisterNetEvent('nx-core:client:spawn', function(pos)
    if loaded then return end
    local model = joaat('mp_m_freemode_01')
    RequestModel(model)
    local tries=0
    while not HasModelLoaded(model) and tries<100 do Wait(100) tries=tries+1 end
    if not HasModelLoaded(model) then print('[NX-Core] Error cargando modelo') return end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)
    RequestCollisionAtCoord(pos.x,pos.y,pos.z)
    SetEntityCoordsNoOffset(PlayerPedId(),pos.x,pos.y,pos.z,false,false,false)
    SetEntityHeading(PlayerPedId(),pos.w or 0.0)
    NetworkResurrectLocalPlayer(pos.x,pos.y,pos.z,pos.w or 0.0,true,false)
    ClearPedTasksImmediately(PlayerPedId())
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    DoScreenFadeIn(700)
    loaded=true
    if data then print('[NX-Core] Bienvenido, '..data.firstname) end
end)
CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(500) end
    Wait(1500)
    TriggerServerEvent('nx-core:server:ready')
    while true do
        Wait(60000)
        if loaded then
            local ped=PlayerPedId()
            local c=GetEntityCoords(ped)
            TriggerServerEvent('nx-core:server:savePosition', {x=c.x,y=c.y,z=c.z,w=GetEntityHeading(ped)})
        end
    end
end)
RegisterCommand('miperfil', function()
    if data then
        TriggerEvent('chat:addMessage',{args={'NX-Core', ('ID %s | %s %s | Efectivo $%s | Banco $%s | Trabajo %s'):format(data.id,data.firstname,data.lastname,data.cash,data.bank,data.job)}})
    end
end, false)
exports('GetPlayerData', function() return data end)
