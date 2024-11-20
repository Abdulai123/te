function displaycapd(pa)
    ngx.header.content_type = "text/html"
    local cookie, err = cook:new()
    if not cookie then
        ngx.log(ngx.ERR, err)
        ngx.say("cookie error")
        ngx.exit(200)
    end

    local blocked_cookies = ngx.shared.blocked_cookies
    local field, err = cookie:get("dcap")
    plaintext = decrypt(field)
    cookdata = split(plaintext, "|")

    if (cookdata[2] == "cap_not_solved") then
        if (cookdata[6] == "3") then
            blocked_cookies:set(field, 1, 120)
            local ni = random.number(5,20)
            local tstamp = ngx.now() + ni
            local plaintext = random.token(random.number(5, 20)) .. "|queue|" .. tstamp .. "|" .. pa .. "|"
            local ciphertext = encrypt(plaintext)
            cookie:set(
            {
                key = "dcap",
                value = ciphertext,
                path = "/",
                domain = ngx.var.host,
                httponly = true,
                max_age = 30,
                samesite = "Lax"
            })
            ngx.header["Refresh"] = ni
            ngx.header.content_type = "text/html"
            local file = io.open("/etc/nginx/resty/queue.html")
            local queue, err = file:read("*a")
            file:close()
            ngx.say(queue)
            ngx.flush()
            ngx.exit(200)
        end
    end

    local function getChallenge()
        local success, module = pcall(require, "challenge")
        if not success then
            ngx.header["Refresh"] = '5'
            ngx.say("Captcha racetime condition hit. Refreshing in 5 seconds.")
            ngx.exit(200)
        end
        local ni = random.number(0,49)
        if challengeArray[ni] ~= nil then
            local challenge = challengeArray[ni]
            return split(challenge, "*")
        else
            ngx.header["Refresh"] = '5'
            ngx.say("Captcha racetime condition hit. Refreshing in 5 seconds.")
            ngx.exit(200)
        end
    end

    local im = getChallenge()
    local challengeStyle = im[1]
    local challengeAnswer = im[2]
    local challengeImage = im[3]

    local tstamp = ngx.now()
    local newcookdata = random.token(random.number(5, 20)) .. "|cap_not_solved|" .. tstamp .. "|" .. pa .. "|" .. challengeAnswer

    if (cookdata[2] == "queue") then
        newcookdata = newcookdata .. "|1"
    else
        newcookdata = newcookdata .. "|" .. tonumber(cookdata[6] + 1)
    end
    local ciphertext = encrypt(newcookdata)
    local ok, err =
        cookie:set(
        {
            key = "dcap",
            value = ciphertext,
            path = "/",
            domain = ngx.var.host,
            httponly = true,
            samesite = "Lax"
        }
    )

    blocked_cookies:set(field, 1, 120)

    if not ok then
        ngx.say("cookie error")
        ngx.exit(200)
    end

ngx.say([[<!DOCTYPE html>
    <html lang=en>
    <head>
    <title>DDOS Protection</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link id="favicon" rel="shortcut icon" href="data:image/x-icon;base64,AAABAAEAEBAAAAEAIABoBAAAFgAAACgAAAAQAAAAIAAAAAEAIAAAAAAAAAQAABMLAAATCwAAAAAAAAAAAACtRI7/rUSO/61Ejv+tRI7/rUSO/61Fjv+qPor/pzaG/6k7if+sQo3/qDiH/6g4h/+sQ43/rUSO/61Ejv+tRI7/rUSO/61Ejv+tRI7/rUSO/61Fjv+sQo3/uV6e/8iBs/+9aaT/sEyT/8V7r//Feq//sEqS/6xDjf+tRI7/rUSO/61Ejv+tRI7/rUSO/65Fj/+vR5D/rEGM/+fI3v///////fv8/+/a6f/+/f7/+vT4/7Zam/+rP4v/rkWP/61Ejv+tRI7/rUSO/61Fjv+sQYz/qTqI/6g4h//hudX/5sXc/+7Z6P////////7///ft9P+2WZr/q0CL/61Fj/+tRI7/rUSO/61Fj/+rQIv/uFyd/82Ou//Njrv/uWGf/6g6iP+uR5D/5sbc///////47vX/tlma/6s/i/+tRY//rUSO/61Ejv+uRo//qDqI/9aix///////69Hj/61Ejv+vSJD/qTqI/8BvqP//////+O/1/7ZZmv+rP4v/rUWP/61Ejv+tRI7/rkaP/6k8if/fttP//////9ekyP+oOIf/sEuS/6tAi/+7ZKH//vv9//nw9v+2WJr/qz+L/61Fj/+tRI7/rUSO/65Gj/+oOoj/1qHG///////pzeH/qj6K/6o8if+lMoP/0pjB///////47vX/tlma/6s/i/+tRY//rUSO/61Ejv+uRo//qj2K/7xmo//8+Pv//////+G61f+8ZqP/zpC8//v2+v//////+O/1/7ZZmv+rP4v/rUWP/61Ejv+tRI7/rUSO/65Gj/+pPIn/zo+7//79/v///////////////////v////////jw9v+2WZr/qz+L/61Fj/+tRI7/rUSO/61Ejv+tRI7/rUWP/6o9iv/Ab6j/37bT/+vR4//kwdr/16XI//36/P/58ff/tlma/6s/i/+tRY//rUSO/61Ejv+tRI7/rUSO/61Ejv+uRo//qj2K/6o9if+tRY7/qDmH/7VYmv/9+fv/+fH3/7ZYmv+rP4v/rUWP/61Ejv+tRI7/rUSO/61Ejv+tRI7/rUSO/65Gj/+uRo//rkaP/6s/i/+6Y6H//Pf6//ju9f+1WJr/q0CL/61Fj/+tRI7/rUSO/61Ejv+tRI7/rUSO/61Ejv+tRI7/rUSO/65Gj/+qPor/umOh//79/v/69Pj/tlqb/6s/i/+uRY//rUSO/61Ejv+tRI7/rUSO/61Ejv+tRI7/rUSO/61Ejv+tRI7/rEKN/7FNk//GfLD/xHmu/7BKkv+sQ43/rUSO/61Ejv+tRI7/rUSO/61Ejv+tRI7/rUSO/61Ejv+tRI7/rUSO/61Ejv+sQo3/qDiH/6g4h/+sQ43/rUSO/61Ejv+tRI7/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==">
    </head><body><style>]])

    local file = io.open("/etc/nginx/resty/cap_d.css")

    if not file then
        ngx.exit(500)
    end

    local css, err = file:read("*a")

    file:close()

    ngx.say(css)

    ngx.say(challengeStyle)

ngx.say([[</style>
    <div class="container">
        <div class="left">
            <div class="networkLogo slide-right-ani">
                <div class="square"></div>
            <div class="text">
                    <span>dread</span>
                    <div class="sm">network</div>
                </div>
            </div>
            <div class="cont">
                <div class="serviceLogo slide-right-ani">
                    <div class="square"></div>
                    <div class="text">dread</div>
                </div>
                <div class="tagline slide-right-ani">the frontpage of the dark net</div>
                <div class="since slide-right-ani">since 2018</div>
            </div>
        </div>
    <div class="inner">]])
    if caperror ~= nil then
        ngx.say('<p class="slide-left-ani alert"><strong>' .. caperror .. '</strong></p>')
    else
        ngx.say('<p class="slide-left-ani">Select each text box and enter the letter or number you see within the circle below.</p>')
    end
    ngx.say([[<form class="ddos_form slide-left-ani" method="post">
        <div class="input-box">
        <input class="ch" type="text" name="c1" maxlength="1" pattern="[A-Za-z0-9]" autocomplete="off" autofocus>]])
    for i = 2, 6, 1 do
        ngx.say('<input class="ch" type="text" name="c' .. i .. '" maxlength="1" pattern="[A-Za-z0-9]" autocomplete="off">')
    end
    ngx.say('<div class="image" style="background-image:url(data:image/webp;base64,' .. challengeImage .. ');"></div>')
ngx.say([[</div>
        <div class="expire">
            <div class="timer">
                <div class="time-part-wrapper">
                    <div class="time-part seconds tens">
                        <div class="digit-wrapper">
                            <span class="digit">0</span>
                            <span class="digit">5</span>
                            <span class="digit">4</span>
                            <span class="digit">3</span>
                            <span class="digit">2</span>
                            <span class="digit">1</span>
                            <span class="digit">0</span>
                        </div>
                    </div>
                    <div class="time-part seconds ones">
                        <div class="digit-wrapper">
                            <span class="digit">0</span>
                            <span class="digit">9</span>
                            <span class="digit">8</span>
                            <span class="digit">7</span>
                            <span class="digit">6</span>
                            <span class="digit">5</span>
                            <span class="digit">4</span>
                            <span class="digit">3</span>
                            <span class="digit">2</span>
                            <span class="digit">1</span>
                            <span class="digit">0</span>
                        </div>
                    </div>
                </div>
                <div class="time-part-wrapper">
                    <div class="time-part hundredths tens">
                        <div class="digit-wrapper">
                            <span class="digit">0</span>
                            <span class="digit">9</span>
                            <span class="digit">8</span>
                            <span class="digit">7</span>
                            <span class="digit">6</span>
                            <span class="digit">5</span>
                            <span class="digit">4</span>
                            <span class="digit">3</span>
                            <span class="digit">2</span>
                            <span class="digit">1</span>
                            <span class="digit">0</span>
                        </div>
                    </div>
                    <div class="time-part hundredths ones">
                        <div class="digit-wrapper">
                            <span class="digit">0</span>
                            <span class="digit">9</span>
                            <span class="digit">8</span>
                            <span class="digit">7</span>
                            <span class="digit">6</span>
                            <span class="digit">5</span>
                            <span class="digit">4</span>
                            <span class="digit">3</span>
                            <span class="digit">2</span>
                            <span class="digit">1</span>
                            <span class="digit">0</span>
                        </div>
                    </div>
                </div>
            </div>
        </div><button class="before" type="submit">Submit</button>
        <button class="expired" type="submit"> Refresh (expired)</button>
        </form>
        </div>
        </div>
    </body>
</html>]])
--if you need the answer right away for testing
--ngx.say(challengeAnswer)
end
