-- love.load
function love.load()
    balls = {
        { x=200, y=300, vx=200, vy=0, r=40, mass=0.5, color={0.9,0.35,0.3} },
        { x=600, y=300, vx=-80, vy=0, r=30, mass=1, color={0.25,0.55,0.85} },
    }
    restitution = 0.85   -- e: 1=elastic, 0=inelastic
end

-- love.update
function love.update(dt)
    -- 1. Integrate positions
    for _, b in ipairs(balls) do
        b.x = b.x + b.vx * dt
        b.y = b.y + b.vy * dt
    end

    -- 2. Resolve all pairs
    for i = 1, #balls do
        for j = i+1, #balls do
            resolve(balls[i], balls[j])
        end
    end

    -- 3. Bounce off walls
    for _, b in ipairs(balls) do
        if b.x - b.r < 0   then b.x = b.r;               b.vx = math.abs(b.vx) end
        if b.x + b.r > 800 then b.x = 800 - b.r;         b.vx = -math.abs(b.vx) end
        if b.y - b.r < 0   then b.y = b.r;               b.vy = math.abs(b.vy) end
        if b.y + b.r > 600 then b.y = 600 - b.r;         b.vy = -math.abs(b.vy) end
    end
end

function resolve(a, b)
    local dx = b.x - a.x
    local dy = b.y - a.y
    local dist = math.sqrt(dx*dx + dy*dy)
    local minDist = a.r + b.r

    -- No overlap → nothing to do
    if dist >= minDist or dist < 0.001 then return end

    -- ── Collision normal (unit vector from A toward B) ──
    local nx = dx / dist
    local ny = dy / dist

    -- ── Positional correction (push them apart so they don't stick) ──
    local overlap = minDist - dist
    local totalMass = a.mass + b.mass
    a.x = a.x - nx * overlap * (b.mass / totalMass)
    a.y = a.y - ny * overlap * (b.mass / totalMass)
    b.x = b.x + nx * overlap * (a.mass / totalMass)
    b.y = b.y + ny * overlap * (a.mass / totalMass)

    -- ── Relative velocity along the normal ──
    local dvx = a.vx - b.vx
    local dvy = a.vy - b.vy
    local vRel = dvx * nx + dvy * ny

    -- Already separating? Don't apply impulse
    if vRel > 0 then return end

    -- ── Impulse scalar  J = -(1+e) * vRel / (1/m1 + 1/m2) ──
    local e = restitution
    local J = -(1 + e) * vRel / (1/a.mass + 1/b.mass)

    -- ── Newton's 3rd Law: equal & opposite impulse ──
    -- A receives  +J along n,  B receives  -J along n
    a.vx = a.vx + (J / a.mass) * nx
    a.vy = a.vy + (J / a.mass) * ny
    b.vx = b.vx - (J / b.mass) * nx
    b.vy = b.vy - (J / b.mass) * ny
end

function love.draw()
    for _, b in ipairs(balls) do
        love.graphics.setColor(b.color)
        love.graphics.circle("fill", b.x, b.y, b.r)
        love.graphics.setColor(1,1,1,0.15)
        love.graphics.circle("line", b.x, b.y, b.r)
    end
end
