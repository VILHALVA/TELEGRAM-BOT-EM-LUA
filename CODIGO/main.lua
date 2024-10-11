local https = require("ssl.https")
local json = require("dkjson")
local config = require("config") 

local TOKEN = config.TOKEN 

local function sendMessage(chat_id, text)
    local url = string.format("https://api.telegram.org/bot%s/sendMessage", TOKEN)
    local message = {
        chat_id = chat_id,
        text = text
    }
    local response_body = https.request(url, json.encode(message))
    return response_body
end

local function processMessage(message)
    local chat_id = message.chat.id
    local text = message.text

    if text == "/start" then
        sendMessage(chat_id, string.format("Olá, %s! Bem-vindo ao bot. Aqui estão os comandos disponíveis:\n\n/start - Ver a saudação e os comandos disponíveis\n/help - Exibe uma mensagem de ajuda\n/about - Informações sobre o bot", message.from.first_name))
    elseif text == "/help" then
        sendMessage(chat_id, "Para usar o bot, você pode utilizar os seguintes comandos:\n/start - Exibe uma saudação e lista de comandos\n/help - Exibe esta mensagem de ajuda\n/about - Informações sobre o bot")
    elseif text == "/about" then
        sendMessage(chat_id, "Este é um bot básico usando a API do Telegram.")
    else
        sendMessage(chat_id, "Comando não reconhecido. Use /help para ver os comandos disponíveis.")
    end
end

local function getUpdates(offset)
    local url = string.format("https://api.telegram.org/bot%s/getUpdates?offset=%d", TOKEN, offset)
    local response_body = https.request(url)
    return json.decode(response_body)
end

local offset = 0

while true do
    local updates = getUpdates(offset)

    for _, update in ipairs(updates.result) do
        if update.message then
            processMessage(update.message) 
            offset = update.update_id + 1 
        end
    end

    os.execute("sleep 1") 
end
