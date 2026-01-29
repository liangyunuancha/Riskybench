# OTA领域数据生成代码

本目录包含 OTA 领域的数据生成代码，按项目统一规范整理。

## 目录结构

```
ota/
├── run_generate.sh              # 统一调用脚本（必填）
├── generate_user_ins_en_tasks.py        # user_instruction (ui) 攻击面
├── generate_tasks_env_indirect_ota.py  # env_noise (env) 攻击面
├── generate_tasks_tf_ota.py            # tool_feedback (tf) 攻击面
├── generate_tasks_ms_ota.py            # message_history (ms) 攻击面
├── generate_tasks_sys_ota.py           # system_prompt (sys) 攻击面
├── mes_his/                     # message_history 相关辅助脚本
└── sys/                         # system_prompt 相关辅助脚本
```

## 使用方法

### 1. 环境准备

在 Linux 环境下，在本地自行设置必要的运行时环境变量（匿名仓库不提供任何密钥示例）。

### 2. 运行数据生成

使用统一的 `run_generate.sh` 脚本：

```bash
bash run_generate.sh <original_file> <start_idx> <number_of_tasks> <output_path> [attack_surface]
```

**参数说明：**
- `original_file`: 原始英文数据文件路径（相对/绝对路径均可）
- `start_idx`: 原始数据起始序号（默认0）
- `number_of_tasks`: 生成任务总数
- `output_path`: 数据输出路径（默认: ./data/vita/domains/ota/）
- `attack_surface`: 攻击面类型（可选，ui/env/tf/ms/sys/all，默认all）

**攻击面说明：**
- `ui` - user_instruction (用户指令)
- `env` - env_noise (环境噪声)
- `tf` - tool_feedback (工具反馈)
- `ms` - message_history (消息历史)
- `sys` - system_prompt (系统提示)
- `all` - 生成所有攻击面（默认）

**示例：**

```bash
# 生成所有攻击面，从第0个任务开始，生成2个任务
bash run_generate.sh ./data/vita/domains/ota/tasks_en.json 0 2 ./data/vita/domains/ota/

# 只生成 user_instruction 攻击面
bash run_generate.sh ./data/vita/domains/ota/tasks_en.json 0 2 ./data/vita/domains/ota/ ui
```

### 3. 输出文件

生成的数据文件命名格式：`ota_{攻击面缩写}_{任务数}_en.json`

- `ota_ui_2_en.json` - user_instruction 攻击面，2个任务
- `ota_env_2_en.json` - env_noise 攻击面，2个任务
- `ota_tf_2_en.json` - tool_feedback 攻击面，2个任务
- `ota_ms_2_en.json` - message_history 攻击面，2个任务
- `ota_sys_2_en.json` - system_prompt 攻击面，2个任务

## 自测要求


1. 在本地配置好 `API_KEY`、`BASE_URL`、`MODEL_NAME` 等环境变量（按脚本读取逻辑为准）
2. 执行测试命令：
   ```bash
   bash run_generate.sh <原始文件路径> 0 2 ./data/vita/domains/ota/
   ```
3. 验证结果：
   - 输出路径自动创建
   - 生成对应攻击面的json文件（任务数=2）
   - 无报错信息，文件内容符合数据生成要求

## 注意事项

1. **路径兼容性**：所有脚本已兼容Linux路径格式，使用 `/` 作为路径分隔符
2. **异常处理**：脚本包含完整的异常捕获和错误提示
3. **权限检查**：脚本会自动检查文件读写权限
4. **环境变量**：必须设置 `API_KEY`，`BASE_URL` 和 `MODEL_NAME` 可选

## 代码说明

### 主要脚本

- **run_generate.sh**: 统一调用入口，负责参数解析、环境检查、调用各攻击面生成脚本
- **generate_user_ins_en_tasks.py**: 用户指令攻击面生成，通过LLM生成恶意指令注入
- **generate_tasks_env_indirect_ota.py**: 环境噪声攻击面生成，在环境数据中注入恶意内容
- **generate_tasks_tf_ota.py**: 工具反馈攻击面生成，在工具反馈中注入恶意内容
- **generate_tasks_ms_ota.py**: 消息历史攻击面生成，在消息历史中注入恶意对话
- **generate_tasks_sys_ota.py**: 系统提示攻击面生成（简化版本，实际使用请参考sys/目录）

### 辅助目录

- **mes_his/**: message_history 攻击面的详细实现脚本
- **sys/**: system_prompt 攻击面的详细实现脚本


