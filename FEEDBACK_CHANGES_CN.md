# 老师反馈与本次修改

保留原 proposal 的七个主章节及顺序：Student Information、Project Overview、
Background and Motivation、Proposed Methodology、Expected Outcomes、Timeline、References。
新稿约 900 词正文（第 2-6 节，公式与表格按空格计词），参考文献另计。

| 反馈 | 已落实的修改 |
|---|---|
| Pages 打不开 | 提供 docs/index.md 和上传/部署步骤；远程部署成功与否需发布后核实 |
| 核心架构已有先例 | Overview、Background 明确承认 Gui & Kwan、Li 等工作；删除组合本身的创新宣称 |
| 研究问题需重新定位 | 改成 ERB 分组是否比逐频点与普通均匀分组有效，以及适用条件 |
| 缺 bin-wise 对照 | 增加 mvdr_binwise |
| 还需普通平滑对照 | 增加 mvdr_uniform，和 ERB 共用 band 数、三角权重形状及映射规则 |
| 解释 bias-variance | 增加跨随机噪声实现的增益方差探针；强调还要看目标失真和频谱细节 |
| cochlear-domain 不准确 | 改称 ERB-band/cochlear-inspired smoothing，明确不是完整耳蜗或 gammatone 模型 |
| SNR/PSD 估计器不明确 | 写明 1 秒目标缺席校准、固定 noise PSD、0.8 递归功率平滑、非负谱减；初版不使用 decision-directed |
| 尽量复用基础设施 | 使用 MATLAB STFT/ISTFT 和 acousticRoomResponse；MVDR 按标准解实现并做独立 KKT 数值检查 |
| 控制实验规模 | 固定 4 麦几何和声源；2 类干扰 x 3 SNR x 2 RT60；角度实验可选 |
| 混响下的 reference | 使用参考麦克风处混响目标分量，所有方法共用时间和幅度标尺 |
| 指标应有意义 | reference-error ΔSNR、SI-SDR、真实语音 STOI，配合谱图/试听；明确定义 SNR 包括目标失真 |
| 文献需要补足 | 扩充到 10 篇，覆盖 MVDR、Wiener、auditory prior work、ERB、房间模型、SI-SDR/STOI 与神经方法 |
| 现代方法背景 | 讨论 neural mask/covariance estimation，但不将神经网络训练加入实现范围 |

## 初步代码已经包含什么

七个对照系统、已知阵列/声源场景、成熟房间模拟器、统一 PSD 估计器、三种频率
分组、指标导出、统一幅度缩放试听、谱图、真实语音实验循环和独立自检。
默认演示使用合成信号，STOI 置为 NaN，不能当作语音性能结论。

## 需要继续完成什么

1. 确定有许可的真实语音集合、独立开发集/测试集以及足够的说话人覆盖。
2. 用安装了 Phased Array System Toolbox 的环境运行 mvdrweights 交叉检查。
   当前机器没有该工具箱；已经通过的是标准方程、独立 KKT 解和无失真约束检查，
   不能写成“与 MathWorks 工具箱交叉验证完成”。
3. 当前固定校准噪声估计是有条件的初版基线，竞争语音下可能不准。若增加 VAD 或
   自适应噪声跟踪，三种后滤波必须同步使用相同实现。
4. 运行完整真实语音对照，按 utterance 配对统计，并报告不确定性。相同语句的随机
   种子重复不能冒充独立语句或说话人。
5. 24 个 ERB bands 不保证和 24 个 uniform bands 在每个频率的带宽相等；需在开发
   数据上检查 16/24/32-band 灵敏度，避免把更强平均误说成感知机制优势。
6. 当前 direct-path steering 存在混响失配。known_rtf 模式有理想已知 RIR 信息，需
   单独标注，不能混入普通 baseline 后宣称实际录音可达到同样结果。

原 proposal 和课程材料没有被覆盖。新稿与代码是在单独文件夹中准备的。
