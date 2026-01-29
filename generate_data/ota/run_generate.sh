#!/bin/bash

# ==================== OTA领域数据生成统一调用脚本 ====================
# 用法: bash run_generate.sh <original_file> <start_idx> <number_of_tasks> <output_path> [attack_surface]
# 参数说明:
#   original_file: 原始英文数据文件路径
#   start_idx: 原始数据起始序号（默认0）
#   number_of_tasks: 生成任务总数
#   output_path: 数据输出路径（默认: ./data/vita/domains/ota/）
#   attack_surface: 攻击面类型（可选，ui/env/tf/ms/sys，默认生成所有攻击面）

set -e  # 遇到错误立即退出

# 获取脚本所在目录与调用时当前目录（用于相对路径解析）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INITIAL_PWD="${PWD}"
cd "$SCRIPT_DIR"

# ==================== 参数解析 ====================
if [ $# -lt 3 ]; then
    echo "用法: bash run_generate.sh <original_file> <start_idx> <number_of_tasks> <output_path> [attack_surface]"
    echo ""
    echo "参数说明:"
    echo "  original_file   原始英文数据文件路径（相对/绝对路径均可）"
    echo "  start_idx       原始数据起始序号（默认0）"
    echo "  number_of_tasks 生成任务总数"
    echo "  output_path     数据输出路径（默认: ./data/vita/domains/ota/）"
    echo "  attack_surface  攻击面类型（可选，ui/env/tf/ms/sys，默认生成所有攻击面）"
    echo ""
    echo "攻击面说明:"
    echo "  ui  - user_instruction (用户指令)"
    echo "  env - env_noise (环境噪声)"
    echo "  tf  - tool_feedback (工具反馈)"
    echo "  ms  - message_history (消息历史)"
    echo "  sys - system_prompt (系统提示)"
    exit 1
fi

ORIGINAL_FILE="$1"
START_IDX="${2:-0}"
NUMBER_OF_TASKS="$3"
OUTPUT_PATH="${4:-./data/vita/domains/ota/}"
ATTACK_SURFACE="${5:-all}"

# 转换为绝对路径（相对路径以调用时当前目录为基准，便于从项目根执行）
if [[ -n "$ORIGINAL_FILE" && ! "$ORIGINAL_FILE" =~ ^/ ]]; then
    ORIGINAL_FILE="${INITIAL_PWD}/${ORIGINAL_FILE#./}"
fi
if [[ -n "$OUTPUT_PATH" && ! "$OUTPUT_PATH" =~ ^/ ]]; then
    OUTPUT_PATH="${INITIAL_PWD}/${OUTPUT_PATH#./}"
fi
OUTPUT_PATH="${OUTPUT_PATH%/}"

# ==================== 环境变量检查 ====================
if [ -z "$API_KEY" ]; then
    echo "错误: 环境变量 API_KEY 未设置"
    echo "请先设置: export API_KEY='你的模型API密钥'"
    exit 1
fi

if [ -z "$BASE_URL" ]; then
    echo "警告: 环境变量 BASE_URL 未设置，将使用默认值 https://www.openai.com/v1"
    export BASE_URL="${BASE_URL:-https://www.openai.com/v1}"
fi

# 规范化 BASE_URL：避免误填完整 endpoint（/chat/completions）导致 SDK 再拼接一次
BASE_URL="${BASE_URL//$'\r'/}"
BASE_URL="${BASE_URL%%/chat/completions*}"
BASE_URL="${BASE_URL%/}"
export BASE_URL

if [ -z "$MODEL_NAME" ]; then
    echo "警告: 环境变量 MODEL_NAME 未设置，将使用默认值"
    export MODEL_NAME="${MODEL_NAME:-gpt-4.1}"
fi

# ==================== 文件检查 ====================
if [ ! -f "$ORIGINAL_FILE" ]; then
    echo "错误: 原始文件 ${ORIGINAL_FILE} 不存在"
    exit 1
fi

# ==================== 创建输出目录 ====================
mkdir -p "$OUTPUT_PATH"
if [ ! -w "$OUTPUT_PATH" ]; then
    echo "错误: 无权限写入路径 ${OUTPUT_PATH}"
    exit 1
fi

# ==================== 攻击面映射 ====================
declare -A ATTACK_SURFACE_MAP
ATTACK_SURFACE_MAP["ui"]="user_instruction"
ATTACK_SURFACE_MAP["env"]="env_noise"
ATTACK_SURFACE_MAP["tf"]="tool_feedback"
ATTACK_SURFACE_MAP["ms"]="message_history"
ATTACK_SURFACE_MAP["sys"]="system_prompt"

# ==================== 生成函数 ====================
generate_ui() {
    echo "=========================================="
    echo "生成 user_instruction (ui) 攻击面数据..."
    echo "=========================================="
    python3 "$SCRIPT_DIR/generate_user_ins_en_tasks.py" \
        "$ORIGINAL_FILE" \
        "$START_IDX" \
        "$NUMBER_OF_TASKS" \
        "$OUTPUT_PATH/ota_ui_${NUMBER_OF_TASKS}_en.json"
    
    if [ $? -ne 0 ]; then
        echo "错误: user_instruction 数据生成失败"
        return 1
    fi
    echo "✓ user_instruction 数据生成成功"
}

generate_env() {
    echo "=========================================="
    echo "生成 env_noise (env) 攻击面数据..."
    echo "=========================================="
    python3 "$SCRIPT_DIR/generate_tasks_env_indirect_ota.py" \
        "$ORIGINAL_FILE" \
        "$START_IDX" \
        "$NUMBER_OF_TASKS" \
        "$OUTPUT_PATH/ota_env_${NUMBER_OF_TASKS}_en.json"
    
    if [ $? -ne 0 ]; then
        echo "错误: env_noise 数据生成失败"
        return 1
    fi
    echo "✓ env_noise 数据生成成功"
}

generate_tf() {
    echo "=========================================="
    echo "生成 tool_feedback (tf) 攻击面数据..."
    echo "=========================================="
    python3 "$SCRIPT_DIR/generate_tasks_tf_ota.py" \
        "$ORIGINAL_FILE" \
        "$START_IDX" \
        "$NUMBER_OF_TASKS" \
        "$OUTPUT_PATH/ota_tf_${NUMBER_OF_TASKS}_en.json"
    
    if [ $? -ne 0 ]; then
        echo "错误: tool_feedback 数据生成失败"
        return 1
    fi
    echo "✓ tool_feedback 数据生成成功"
}

generate_ms() {
    echo "=========================================="
    echo "生成 message_history (ms) 攻击面数据..."
    echo "=========================================="
    python3 "$SCRIPT_DIR/generate_tasks_ms_ota.py" \
        "$ORIGINAL_FILE" \
        "$START_IDX" \
        "$NUMBER_OF_TASKS" \
        "$OUTPUT_PATH/ota_ms_${NUMBER_OF_TASKS}_en.json"
    
    if [ $? -ne 0 ]; then
        echo "错误: message_history 数据生成失败"
        return 1
    fi
    echo "✓ message_history 数据生成成功"
}

generate_sys() {
    echo "=========================================="
    echo "生成 system_prompt (sys) 攻击面数据..."
    echo "=========================================="
    python3 "$SCRIPT_DIR/generate_tasks_sys_ota.py" \
        "$ORIGINAL_FILE" \
        "$START_IDX" \
        "$NUMBER_OF_TASKS" \
        "$OUTPUT_PATH/ota_sys_${NUMBER_OF_TASKS}_en.json"
    
    if [ $? -ne 0 ]; then
        echo "错误: system_prompt 数据生成失败"
        return 1
    fi
    echo "✓ system_prompt 数据生成成功"
}

# ==================== 主执行逻辑 ====================
echo "=========================================="
echo "OTA领域数据生成开始"
echo "=========================================="
echo "原始文件: $ORIGINAL_FILE"
echo "起始序号: $START_IDX"
echo "任务数量: $NUMBER_OF_TASKS"
echo "输出路径: $OUTPUT_PATH"
echo "攻击面: $ATTACK_SURFACE"
echo "=========================================="

ERROR_COUNT=0

if [ "$ATTACK_SURFACE" = "all" ]; then
    # 生成所有攻击面
    generate_ui || ((ERROR_COUNT++))
    generate_env || ((ERROR_COUNT++))
    generate_tf || ((ERROR_COUNT++))
    generate_ms || ((ERROR_COUNT++))
    generate_sys || ((ERROR_COUNT++))
else
    # 生成指定攻击面
    case "$ATTACK_SURFACE" in
        ui)
            generate_ui || ((ERROR_COUNT++))
            ;;
        env)
            generate_env || ((ERROR_COUNT++))
            ;;
        tf)
            generate_tf || ((ERROR_COUNT++))
            ;;
        ms)
            generate_ms || ((ERROR_COUNT++))
            ;;
        sys)
            generate_sys || ((ERROR_COUNT++))
            ;;
        *)
            echo "错误: 无效的攻击面类型 '$ATTACK_SURFACE'"
            echo "支持的攻击面: ui, env, tf, ms, sys, all"
            exit 1
            ;;
    esac
fi

# ==================== 结果汇总 ====================
echo ""
echo "=========================================="
if [ $ERROR_COUNT -eq 0 ]; then
    echo "✓ 所有数据生成完成！"
    echo "输出文件位于: $OUTPUT_PATH"
    ls -lh "$OUTPUT_PATH"/*.json 2>/dev/null || echo "（未找到输出文件）"
else
    echo "✗ 数据生成完成，但有 $ERROR_COUNT 个攻击面生成失败"
    exit 1
fi
echo "=========================================="
