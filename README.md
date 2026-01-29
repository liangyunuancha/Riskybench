<div align=center><h1>
    🌱 Riskybench: 风险评测与数据生成
</h1></div>

## 📖 简介

**Riskybench** 用于对交互式任务型智能体进行风险相关评测，并提供配套的数据生成脚本与可复现实验入口。为满足论文匿名审稿要求，本仓库已移除与身份/机构相关的外链、致谢、作者信息等内容。

- **数据生成逻辑**（`generate_data/`）：支持多领域、多攻击面的评测数据生成，便于复现与扩展风险/攻击类实验。
- **扩展的 vita 参数**（`src/vita`）：如任务集选择、自定义数据集文件、系统提示注入、重跑与重评等，满足风险评测与消融实验需求。

评测基于多领域的交互式任务设置（外卖、到店、酒旅等），支持单域与跨域、中英文任务及多种评估类型。

---

## 🌱 项目结构概览

| 模块 | 说明 |
|------|------|
| `generate_data/` | 数据生成脚本：Delivery、Instore、OTA 等领域的多攻击面（ui/env/tf/ms/sys）任务生成 |
| `src/vita/` | 评测核心：agent、environment、evaluator、CLI 及扩展参数 |
| `data/vita/domains/` | 各领域任务与跨域任务数据（如 `tasks.json`、`tasks_en.json`） |

---

## 🛠️ 快速开始

### 安装

在项目根目录下安装依赖并启用 `vita` 命令：

```bash
pip install -e .
```

### 配置 LLM（models.yaml）

可通过环境变量指定模型配置路径（默认：`src/vita/models.yaml`）：

```bash
export VITA_MODEL_CONFIG_PATH=./src/vita/models.yaml
```

示例 `models.yaml`：

```yaml
default:
  base_url: <base url>
  temperature: 0.0
  max_input_tokens: 32768
  headers:
    Content-Type: "application/json"

models:
  - name: <model name>
    max_tokens: 8192
    max_input_tokens: 32768
```

### 运行评测（vita run）

```bash
vita run \
  --domain <domain> \                    # 单域: delivery / instore / ota；跨域: delivery,instore,ota
  --user-llm <model name> \
  --agent-llm <model name> \
  --evaluator-llm <model name> \
  --enable-think \                       # 可选，启用 agent 思考模式
  --num-trials 1 \                       # 可选，每任务运行次数，默认 1
  --num-tasks 1 \                        # 可选，运行任务数量
  --task-ids 1 2 3 \                     # 可选，仅运行指定任务 ID
  --max-steps 300 \                      # 可选，单次仿真最大步数
  --max-concurrency 1 \                  # 可选，并发数
  --csv-output <csv path> \              # 可选，结果追加到 CSV
  --language <chinese/english> \         # 可选，默认 chinese
  --task-set-name <name> \               # 可选，指定任务集（与 domain 一致或 cross_domain）
  --dataset-file <filename> \           # 可选，自定义任务文件名（如生成的数据文件）
  --system-prompt-injection <text> \     # 可选，向 agent 系统提示追加的注入内容
  --re-evaluate-file <path> \            # 可选，重评模式：指定已有仿真结果文件
  --re-run \                             # 可选，与 --re-evaluate-file 配合，重跑指定任务后再整体重评
  --save-to <path>                       # 可选，仿真结果保存路径
```

结果默认落在 `data/simulations/`。

### 重评已有仿真

```bash
vita run \
  --re-evaluate-file <simulation file path> \
  --evaluation-type <evaluation type> \
  --evaluator-llm <evaluation model> \
  --save-to <new simulation file path>
```

### 查看结果

```bash
vita view --file <simulation file path>
vita view --file <path> --only-show-failed
vita view --file <path> --only-show-all-failed
```

### 数据生成（generate_data）

在**项目根目录**下执行。为避免在匿名仓库中出现任何密钥相关内容，本 README 不包含 API key 示例；请在本地环境中自行配置所需的运行时环境变量。

统一调用格式：

```bash
bash generate_data/<领域>/run_generate.sh <original_file> <start_idx> <number_of_tasks> <output_path> [攻击面]
```

| 参数 | 说明 |
|------|------|
| original_file | 原始英文任务文件（如 `./data/vita/domains/<领域>/tasks_en.json`） |
| start_idx | 起始任务下标（从 0 开始） |
| number_of_tasks | 生成任务数量 |
| output_path | 输出目录（建议 `./data/vita/domains/<领域>/`） |
| 攻击面 | **仅 OTA** 支持：ui / env / tf / ms / sys / all，默认 all |

**示例（建议先试跑 1 个任务）：**

```bash
# Delivery
bash generate_data/delivery/run_generate.sh \
  ./data/vita/domains/delivery/tasks_en.json 0 1 ./data/vita/domains/delivery/

# OTA（仅 ui）
bash generate_data/ota/run_generate.sh \
  ./data/vita/domains/ota/tasks_en.json 0 1 ./data/vita/domains/ota/ ui

# Instore
bash generate_data/instore/run_generate.sh \
  ./data/vita/domains/instore/tasks_en.json 0 1 ./data/vita/domains/instore/
```

生成文件命名：`{领域}_{攻击面}_{任务数}_en.json`。使用自定义生成文件进行评测时，可将生成的文件放入 `data/vita/domains/<领域>/`，再通过 `--dataset-file <filename>` 指定。

更详细的配置与各领域说明见：

- [generate_data/README.md](generate_data/README.md)
- [generate_data/delivery/README.md](generate_data/delivery/README.md)
- [generate_data/ota/README.md](generate_data/ota/README.md)

---

## 📜 License

本项目采用 MIT License，详见 [LICENSE](./LICENSE)。

## 📪 Support

如有问题或建议，请在仓库中提 Issue 或联系维护者。
