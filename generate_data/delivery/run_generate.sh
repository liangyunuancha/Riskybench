#!/usr/bin/env bash
# delivery 领域数据生成统一入口
# 用法: bash run_generate.sh <original_file> <start_idx> <number_of_tasks> <output_path>
# 示例: bash run_generate.sh ./data/vita/domains/delivery/tasks_en.json 0 2 ./data/vita/domains/delivery/

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INITIAL_PWD="${PWD}"
cd "$SCRIPT_DIR"

# 必选参数（相对路径视为相对于调用脚本时的当前目录）
original_file="${1:-}"
start_idx="${2:-0}"
number_of_tasks="${3:-}"
output_path="${4:-./data/vita/domains/delivery}"

# 转为绝对路径，便于在 delivery 目录下执行 Python 时仍能找到文件
[ -n "$original_file" ] && [[ "$original_file" != /* ]] && original_file="${INITIAL_PWD}/${original_file}"
[ -n "$output_path" ] && [[ "$output_path" != /* ]] && output_path="${INITIAL_PWD}/${output_path}"

# 参数数量检查（至少需要 original_file 和 number_of_tasks）
if [ -z "$original_file" ] || [ -z "$number_of_tasks" ]; then
    echo "用法: bash run_generate.sh <original_file> <start_idx> <number_of_tasks> <output_path>"
    echo "  original_file   - 原始英文数据文件路径（相对/绝对均可）"
    echo "  start_idx       - 原始数据起始序号（默认 0）"
    echo "  number_of_tasks - 生成任务总数"
    echo "  output_path     - 数据输出目录（默认 ./data/vita/domains/delivery/）"
    exit 1
fi

# 默认 start_idx
if [ -z "$start_idx" ] || [ "$start_idx" = "" ]; then
    start_idx=0
fi

# 环境变量检查
if [ -z "${API_KEY:-}" ]; then
    echo "Error: 请设置环境变量 API_KEY"
    exit 1
fi
if [ -z "${BASE_URL:-}" ]; then
    echo "警告: 环境变量 BASE_URL 未设置，使用默认值 https://www.openai.com/v1"
    export BASE_URL="https://www.openai.com/v1"
fi

# 规范化 BASE_URL：避免误填完整 endpoint（/chat/completions）导致 SDK 再拼接一次
BASE_URL="${BASE_URL//$'\r'/}"
BASE_URL="${BASE_URL%%/chat/completions*}"
BASE_URL="${BASE_URL%/}"
export BASE_URL
if [ -z "${MODEL_NAME:-}" ]; then
    echo "Error: 请设置环境变量 MODEL_NAME"
    exit 1
fi

# 输出目录自动创建
mkdir -p "$output_path"

# 规范化 output_path（去除末尾 / 以便一致拼接）
output_path="${output_path%/}"

# 调用 Python 统一入口
if ! python3 run_generate.py "$original_file" "$start_idx" "$number_of_tasks" "$output_path"; then
    echo "Error: Python 数据生成执行失败"
    exit 1
fi

echo "delivery 数据生成完成，输出目录: $output_path"
