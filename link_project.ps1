# Run as Admin
# Ajuste os caminhos conforme sua máquina

$MT5Root = "$env:APPDATA\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5"
$ProjectRoot = "C:\Workspace\lab_quant_pie_mql5\quant-pie-mql5"

# Pasta Include (SDK)
$IncludeSource = "$ProjectRoot\quant_pie"
$IncludeTarget = "$MT5Root\Include\quant_pie"

# Criação do link da SDK
if (!(Test-Path $IncludeTarget)) {
  New-Item -ItemType SymbolicLink -Path $IncludeTarget -Target $IncludeSource
  Write-Host "Symlink created: quant_pie/"
}
else {
  Write-Host "Symlink already exists: quant_pie/"
}

# Pasta Experts/Bots para os robôs
$BotsFolder = "$MT5Root\Experts\Bots"
if (!(Test-Path $BotsFolder)) {
  New-Item -ItemType Directory -Path $BotsFolder
  Write-Host "Created folder: Experts/Bots"
}

# Estratégia específica
$StrategySource = "$ProjectRoot\bots\trend_adx_mme.mq5"
$StrategyTarget = "$BotsFolder\trend_adx_mme.mq5"

# Criação do link para a estratégia
if (!(Test-Path $StrategyTarget)) {
  New-Item -ItemType SymbolicLink -Path $StrategyTarget -Target $StrategySource
  Write-Host "Symlink created: trend_adx_mme.mq5"
}
else {
  Write-Host "Symlink already exists: trend_adx_mme.mq5"
}

Write-Host ""
Write-Host "All linked! Open MetaEditor and compile."
