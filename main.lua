local recursos = 50000

-- Definindo a classe Mina
Mina = {
    taxaDeProducao = 1,
    custoMelhoria = 10,
    multiplicadorCustoMelhoria = 1.2,
    atualizacoes = 0,
    botaoMelhoria = {
        x = 0,
        y = 0,
        largura = 100,
        altura = 60
    },
    caixaInfo = {
        x = 0,
        y = 0,
        largura = 150,
        altura = 70
    }
}

-- Função para criar o botão de melhoria para cada mina
function Mina:criarBotaoMelhoria(x, y)
    return {
        x = x,
        y = y,
        largura = self.botaoMelhoria.largura,
        altura = self.botaoMelhoria.altura
    }
end

-- Função para criar a caixa de informações para cada mina
function Mina:criarCaixaInfo(x, y)
    return {
        x = x,
        y = y,
        largura = self.caixaInfo.largura,
        altura = self.caixaInfo.altura
    }
end

-- Função para melhorar a mina (aumentar a taxa de produção)
function Mina:melhorar()
    if recursos >= self.custoMelhoria then
        recursos = recursos - self.custoMelhoria
        self.taxaDeProducao = self.taxaDeProducao + 1
        self.custoMelhoria = self.custoMelhoria * self.multiplicadorCustoMelhoria
        self.atualizacoes = self.atualizacoes + 1
    end
end

-- Lista de minas
local minas = {}

-- Criação da primeira mina no início do jogo
local primeiraMina = setmetatable({}, { __index = Mina })
primeiraMina.botaoMelhoria = primeiraMina:criarBotaoMelhoria(200, 10)
primeiraMina.caixaInfo = primeiraMina:criarCaixaInfo(10, 60)
table.insert(minas, primeiraMina)

-- Variável de rolagem
local scrollY = 0

-- Função para criar uma nova mina
function criarNovaMina()
    local novaMina = setmetatable({}, { __index = Mina })
    novaMina.botaoMelhoria = novaMina:criarBotaoMelhoria(200, #minas * 80 + 10)
    novaMina.caixaInfo = novaMina:criarCaixaInfo(10, #minas * 80 + 60)
    return novaMina
end

-- Função chamada quando o mouse é pressionado
function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        for _, mina in ipairs(minas) do
            local botao = mina.botaoMelhoria
            -- Verifica se o botão foi pressionado
            if x >= botao.x and x <= botao.x + botao.largura and y >= botao.y - scrollY and y <= botao.y - scrollY + botao.altura then
                mina:melhorar()
            end
        end
    end
end

-- Função chamada quando a roda do mouse é movida
function love.wheelmoved(x, y)
    scrollY = scrollY - y * 30
    scrollY = math.max(0, scrollY)
end

-- Função de atualização
function love.update(dt)
    for _, mina in ipairs(minas) do
        recursos = recursos + mina.taxaDeProducao * dt

        -- Verifica se uma mina atingiu 10 atualizações e gera uma nova mina
        if mina.atualizacoes == 10 and #minas<=7 then
            local novaMina = criarNovaMina()
            table.insert(minas, novaMina)
            mina.atualizacoes = 20  -- Reinicia o contador
        end
    end
end


-- Função de desenho
function love.draw()
    -- Desenha os recursos à direita em verde
    love.graphics.setColor(0, 1, 0)
    love.graphics.print("Recursos: " .. math.floor(recursos), love.graphics.getWidth() - 150, 10)
    love.graphics.setColor(1, 1, 1)  -- Restaura a cor padrão

    for _, mina in ipairs(minas) do
        local caixa = mina.caixaInfo

        -- Desenha a "caixa" para cada mina
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", caixa.x, caixa.y - scrollY, caixa.largura, caixa.altura)
        love.graphics.setColor(1, 1, 1)

        -- Desenha o texto dentro da "caixa"
        love.graphics.print("Mina - Taxa de produção: " .. mina.taxaDeProducao, caixa.x + 10, caixa.y - scrollY + 20)
        love.graphics.print("Custo de melhoria: " .. math.floor(mina.custoMelhoria), caixa.x + 10, caixa.y - scrollY + 40)

        local botao = mina.botaoMelhoria

        -- Ajusta a posição vertical do botão para estar alinhado com a caixa
        botao.y = caixa.y - scrollY + caixa.altura - botao.altura

        -- Desenha o botão de melhoria para cada mina
        love.graphics.setColor(0, 1, 0)  -- Cor verde
        love.graphics.rectangle("fill", botao.x, botao.y, botao.largura, botao.altura)
        love.graphics.setColor(1, 1, 1)  -- Restaura a cor padrão
        love.graphics.print("Melhorar Minas", botao.x + 10, botao.y + 5)  -- Ajuste da posição vertical
    end
end