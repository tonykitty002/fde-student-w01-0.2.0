#!/usr/bin/env sh
# 启动 W01 标准会员运营 Agent（macOS / Linux / Git Bash）
# 用法： ./run.sh                     默认 start --actions
#        ./run.sh run --text "..."    透传给 tools/product.py
set -e
cd "$(dirname "$0")"

if [ ! -f .model.env ]; then
  echo "缺少 .model.env，请先填写 FDE_MODEL_URL / FDE_MODEL_NAME / FDE_MODEL_KEY / FDE_MODEL_PROFILE" >&2
  exit 1
fi

while IFS= read -r line || [ -n "$line" ]; do
  case "$line" in
    ''|'#'*) continue ;;
  esac
  key=$(printf '%s' "$line" | cut -d= -f1)
  val=$(printf '%s' "$line" | cut -d= -f2-)
  export "$key=$val"
done < .model.env

if [ -x .venv/bin/python ]; then
  PY=.venv/bin/python
elif [ -x .venv/Scripts/python.exe ]; then
  PY=.venv/Scripts/python.exe
else
  echo "未找到 .venv，请先创建虚拟环境并安装 requirements.txt" >&2
  exit 1
fi

echo "模型: ${FDE_MODEL_NAME:-(未设置)}  |  profile: ${FDE_MODEL_PROFILE:-compatible}"

# 第一个参数是子命令就透传，否则默认补 start --actions（便于只用 --port 之类的开关）
case "${1:-}" in
  init|mock|run|serve|start) exec "$PY" tools/product.py "$@" ;;
  *) exec "$PY" tools/product.py start --actions "$@" ;;
esac
