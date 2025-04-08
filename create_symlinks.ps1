# Run this script as Administrator!
# Adjust paths if necessary

# MetaTrader root
$MT5Root = "C:\Users\gabri\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5"

# Your project paths
$ProjectRoot = "C:\Workspace\lab_quant_pie_mql5\quant-pie-mql5"
$IncludeSource = "$ProjectRoot\include"
$StrategySource = "$ProjectRoot\strategies\trend_adx_mme.mq5"
$DebugSource = "$ProjectRoot\debug"
$VisualizersSource = "$ProjectRoot\visualizers"

# Target paths
$IncludeTarget = "$MT5Root\Include\quant_pie"
$StrategyTarget = "$MT5Root\Experts\trend_adx_mme.mq5"
$DebugTarget = "$MT5Root\Experts\debug"
$VisualizersTarget = "$MT5Root\Experts\visualizers"

# Create symlink for include/
if (!(Test-Path $IncludeTarget)) {
  New-Item -ItemType SymbolicLink -Path $IncludeTarget -Target $IncludeSource
  Write-Host "✔ Symlink created: include/"
}
else {
  Write-Host "⚠ Symlink already exists: include/"
}

# Create symlink for strategy
if (!(Test-Path $StrategyTarget)) {
  New-Item -ItemType SymbolicLink -Path $StrategyTarget -Target $StrategySource
  Write-Host "✔ Symlink created: trend_adx_mme.mq5"
}
else {
  Write-Host "⚠ Symlink already exists: trend_adx_mme.mq5"
}

# Create symlink for debug/
if (!(Test-Path $DebugTarget)) {
  New-Item -ItemType SymbolicLink -Path $DebugTarget -Target $DebugSource
  Write-Host "✔ Symlink created: debug/"
}
else {
  Write-Host "⚠ Symlink already exists: debug/"
}

# Create symlink for visualizers/
if (!(Test-Path $VisualizersTarget)) {
  New-Item -ItemType SymbolicLink -Path $VisualizersTarget -Target $VisualizersSource
  Write-Host "✔ Symlink created: visualizers/"
}
else {
  Write-Host "⚠ Symlink already exists: visualizers/"
}

Write-Host "`n✅ All done! Open MetaEditor and compile your EAs, Debugs and Visualizers 🚀"
