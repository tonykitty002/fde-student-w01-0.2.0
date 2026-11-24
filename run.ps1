# 启动 W01 标准会员运营 Agent（Windows PowerShell）
# 用法： .\run.ps1              默认 start --actions
#        .\run.ps1 run --text "..."  透传给 tools/product.py
$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

$envFile = Join-Path $PSScriptRoot '.model.env'
if (-not (Test-Path $envFile)) {
    Write-Host "缺少 .model.env，请先填写 FDE_MODEL_URL / FDE_MODEL_NAME / FDE_MODEL_KEY / FDE_MODEL_PROFILE" -ForegroundColor Red
    exit 1
}

foreach ($line in Get-Content $envFile -Encoding UTF8) {
    $t = $line.Trim()
    if ($t -eq '' -or $t.StartsWith('#')) { continue }
    $i = $t.IndexOf('=')
    if ($i -lt 1) { continue }
    $name = $t.Substring(0, $i).Trim()
    $value = $t.Substring($i + 1).Trim()
    Set-Item -Path ("Env:" + $name) -Value $value
}

$py = Join-Path $PSScriptRoot '.venv\Scripts\python.exe'
if (-not (Test-Path $py)) {
    Write-Host "未找到 .venv，请先执行： python -m venv .venv 并安装 requirements.txt" -ForegroundColor Red
    exit 1
}

$model = if ($env:FDE_MODEL_NAME) { $env:FDE_MODEL_NAME } else { '(未设置)' }
Write-Host "模型: $model  |  profile: $($env:FDE_MODEL_PROFILE)" -ForegroundColor Cyan

# 第一个参数是子命令就透传，否则默认补 start --actions（便于只用 --port 之类的开关）
$commands = @('init', 'mock', 'run', 'serve', 'start')
if ($args.Count -gt 0 -and $commands -contains $args[0]) {
    & $py tools/product.py @args
} else {
    & $py tools/product.py start --actions @args
}
