# Delivery 领域数据生成

按项目数据生成规范整理，与目录结构、参数及命名一致。

## 调用方式

**建议在项目根目录下执行**，以便使用相对路径：

```bash
bash generate_data/delivery/run_generate.sh <original_file> <start_idx> <number_of_tasks> <output_path>
```

### 参数说明

| 参数 | 说明 |
|------|------|
| original_file | 原始英文数据文件路径（相对/绝对均可，相对路径相对于执行脚本时的当前目录） |
| start_idx | 原始数据起始序号（默认 0） |
| number_of_tasks | 生成任务总数（自测建议 2） |
| output_path | 数据输出目录（默认 `./data/vita/domains/delivery/`） |

### 环境变量（必填）

- `API_KEY`：运行时密钥（请勿提交到匿名仓库）  
- `BASE_URL`：模型调用基础地址（可选）  
- `MODEL_NAME`：使用的模型名称（可选）  

### 自测示例

在本地环境中配置必要的环境变量后执行：

```bash
bash generate_data/delivery/run_generate.sh ./data/vita/domains/delivery/tasks_en.json 0 2 ./data/vita/domains/delivery/
```

## 输出规范

- 输出路径若不存在会自动创建。
- 生成文件命名：`delivery_{攻击面}_{任务数}_en.json`
- 当前接入攻击面：**ui**（user_instruction）、**env**（env_noise）、**ms**（message_history）。  
  tf（tool_feedback）、sys（system_prompt）可后续在 `run_generate.py` 中扩展。

## 目录说明

- `run_generate.sh`：唯一入口脚本，负责参数校验、环境变量检查、调用 Python。
- `run_generate.py`：统一入口，按攻击面调度各子脚本。
- `Delivery-User/`：user_instruction（ui）生成逻辑。
- `Delivery-Environmental/`：env_noise（env）生成逻辑。
- `Del-mem/`：message_history（ms）生成逻辑。
- `Del-tool/`、`Del-sys/`：工具与系统提示相关代码，当前未接入统一 4 参数接口。
