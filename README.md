# Portfolio
## Scripts/

### Security tp by [+1 Speed Simulador]
```txt
link [ https://www.roblox.com/pt/games/79677384187999/1-Simulador-de-Velocidade-Mapa-do-Caos ]
```



### ===/===/=== {como aplicar:} ===\===\===

#### WorkSpace:
```txt
Parts = {
ex: [1][2][3][4][5]
}
```

#### ServerScriptService:
```txt
script: SecurityTpServerMth.lua
```

#### ReplicatedStorage:
```txt
Part: Reward (a part de ganho)
```

#### StarterPlayer/StarterPlayerScripts:
```txt
Local Script: SecurityRewardClientMth.lua
```




### ===/===/=== {como funciona:} ==\===\===
```txt
O jogador precisa passar pelas partes `1` até `5` na ordem correta. Cada etapa possui um tempo mínimo para ser alcançada. Se o jogador tentar pular partes, chegar rápido demais ou usar teleport, o servidor detecta a irregularidade e envia ele de volta para o último checkpoint válido.
O sistema usa validação no servidor, controle de sequência, tempo entre checkpoints e verificação de movimento para evitar bypass em jogos com personagens rápidos.
```



### ===/===/=== {como configurar:} ========

#### 1. Crie as partes no mapa

No `Workspace`, crie uma pasta chamada:

```txt
SecurityPoints
```

Dentro dela, coloque as 5 partes em ordem:

```txt
Point1
Point2
Point3
Point4
Point5
```

Configuração recomendada para cada parte:

```txt
Anchored = true
CanTouch = true
CanQuery = true
CanCollide = false ou true
```

#### 2. Configure os tempos

No script `SecurityTpServer.lua`, edite:

```lua
MinTimeToNext = {
	[1] = 0.5,
	[2] = 1,
	[3] = 1.5,
	[4] = 2,
}
```

Cada número representa o tempo mínimo para sair de uma parte e chegar na próxima.

#### 3. Configure a velocidade máxima permitida

```lua
MaxActiveSpeed = 450
```

Se o jogo tiver players muito rápidos, aumente o valor.

Exemplo:

```lua
MaxActiveSpeed = 700
```

#### 4. Configure o teleporte de correção

```lua
TeleportYOffset = 3
```

Se o jogador voltar muito alto, diminua para:

```lua
TeleportYOffset = 1.5
```

#### 5. Ajuste a verificação

```lua
ScanInterval = 0.06
```

Valor menor detecta mais rápido.
Valor maior deixa o sistema mais leve.



===/===/===/ Painel de teste para testar o sistema: ===/===/===

### StarterPlayer/StarterPlayerScript:
```txt
PainelHackSctMth.lua
```
