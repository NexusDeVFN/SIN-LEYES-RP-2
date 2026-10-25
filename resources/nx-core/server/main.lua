local Players = {}
local function getLicense(src)
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        if identifier:sub(1, 8) == 'license:' then return identifier end
    end
end
local function validAmount(amount)
    return type(amount) == 'number' and amount == math.floor(amount) and amount > 0 and amount <= 100000000
end
local function sync(src)
    local p = Players[src]
    if p then TriggerClientEvent('nx-core:client:playerData', src, {id=p.id, firstname=p.firstname, lastname=p.lastname, cash=p.cash, bank=p.bank, job=p.job, job_grade=p.job_grade}) end
end
local function loadPlayer(src)
    if not GetPlayerName(src) then return end
    local license = getLicense(src)
    if not license then DropPlayer(src, 'No se encontró tu licencia de Rockstar.') return end
    local rows = MySQL.query.await('SELECT * FROM nx_players WHERE license = ? LIMIT 1', {license})
    local p = rows[1]
    if not p then
        MySQL.insert.await('INSERT IGNORE INTO nx_players (license, cash, bank) VALUES (?, ?, ?)', {license, Config.StartingCash, Config.StartingBank})
        rows = MySQL.query.await('SELECT * FROM nx_players WHERE license = ? LIMIT 1', {license})
        p = rows[1]
    end
    if not p or not GetPlayerName(src) then return end
    Players[src] = p
    sync(src)
    local pos
    if p.position then
        local ok, decoded = pcall(json.decode, p.position)
        if ok and type(decoded) == 'table' and type(decoded.x)=='number' and type(decoded.y)=='number' and type(decoded.z)=='number' then pos = decoded end
    end
    TriggerClientEvent('nx-core:client:spawn', src, pos or {x=Config.DefaultSpawn.x,y=Config.DefaultSpawn.y,z=Config.DefaultSpawn.z,w=Config.DefaultSpawn.w})
    print(('[NX-Core] Cargado %s (%s)'):format(GetPlayerName(src), src))
end
local function savePlayer(src)
    local p = Players[src]
    if not p then return end
    MySQL.update.await('UPDATE nx_players SET firstname=?, lastname=?, cash=?, bank=?, job=?, job_grade=?, position=? WHERE id=?',
        {p.firstname,p.lastname,p.cash,p.bank,p.job,p.job_grade,p.position,p.id})
end
exports('GetPlayer', function(src) return Players[src] end)
exports('GetPlayers', function() return Players end)
exports('AddMoney', function(src, account, amount, reason)
    local p=Players[src]
    if not p or (account~='cash' and account~='bank') or not validAmount(amount) or p[account]+amount>2147483647 then return false end
    local affected=MySQL.update.await(('UPDATE nx_players SET %s = %s + ? WHERE id = ? AND %s <= ?'):format(account,account,account), {amount,p.id,2147483647-amount})
    if affected~=1 then return false end
    p[account]=p[account]+amount
    MySQL.insert.await('INSERT INTO nx_transactions (player_id, account, amount, reason) VALUES (?, ?, ?, ?)', {p.id,account,amount,tostring(reason or 'Sin motivo'):sub(1,100)})
    sync(src)
    return true
end)
exports('RemoveMoney', function(src, account, amount, reason)
    local p=Players[src]
    if not p or (account~='cash' and account~='bank') or not validAmount(amount) or p[account]<amount then return false end
    local affected=MySQL.update.await(('UPDATE nx_players SET %s = %s - ? WHERE id = ? AND %s >= ?'):format(account,account,account), {amount,p.id,amount})
    if affected~=1 then return false end
    p[account]=p[account]-amount
    MySQL.insert.await('INSERT INTO nx_transactions (player_id, account, amount, reason) VALUES (?, ?, ?, ?)', {p.id,account,-amount,tostring(reason or 'Sin motivo'):sub(1,100)})
    sync(src)
    return true
end)
RegisterNetEvent('nx-core:server:ready', function() local src=source if not Players[src] then loadPlayer(src) else sync(src) end end)
RegisterNetEvent('nx-core:server:savePosition', function(pos)
    local src=source
    if not Players[src] or type(pos)~='table' then return end
    for _, key in ipairs({'x','y','z','w'}) do if type(pos[key])~='number' or pos[key]~=pos[key] or math.abs(pos[key])>100000 then return end end
    Players[src].position=json.encode({x=pos.x,y=pos.y,z=pos.z,w=pos.w})
end)
AddEventHandler('playerDropped', function() local src=source if Players[src] then savePlayer(src) Players[src]=nil end end)
CreateThread(function() while true do Wait(Config.SaveInterval) for src in pairs(Players) do savePlayer(src) end end end)
AddEventHandler('onResourceStop', function(name) if name~=GetCurrentResourceName() then return end for src in pairs(Players) do savePlayer(src) end end)
RegisterCommand('nxstatus', function(src)
    if src==0 then print('[NX-Core] Jugadores cargados: '..tostring(#GetPlayers())) return end
    sync(src)
end, false)
