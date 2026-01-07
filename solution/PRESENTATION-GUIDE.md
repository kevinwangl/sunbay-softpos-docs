# SUNBAY SoftPOS 演示文稿使用指南

## 文件说明

`PRESENTATION.md` 是一个 Markdown 格式的演示文稿大纲，包含 30+ 页内容，涵盖：
- 方案概述
- 系统架构
- 核心功能
- 安全保障
- 技术优势
- 项目成果
- 应用场景
- 商业价值

---

## 使用方式

### 方式 1: 直接查看 Markdown（最简单）

直接在任何 Markdown 编辑器中查看 `PRESENTATION.md`：
- VS Code
- Typora
- MacDown
- 在线 Markdown 查看器

---

### 方式 2: 使用 Marp（推荐）

Marp 是一个将 Markdown 转换为 PPT 的工具。

#### 安装 Marp CLI

```bash
npm install -g @marp-team/marp-cli
```

#### 转换为 HTML

```bash
cd docs/solution
marp PRESENTATION.md -o PRESENTATION.html
```

#### 转换为 PDF

```bash
marp PRESENTATION.md -o PRESENTATION.pdf
```

#### 转换为 PowerPoint

```bash
marp PRESENTATION.md -o PRESENTATION.pptx
```

#### 实时预览

```bash
marp -s PRESENTATION.md
```

然后在浏览器中打开 http://localhost:8080

---

### 方式 3: 使用 reveal.js

reveal.js 是一个强大的 HTML 演示框架。

#### 在线转换

访问 https://revealjs.com/ 并使用在线编辑器。

#### 本地使用

1. 克隆 reveal.js：
```bash
git clone https://github.com/hakimel/reveal.js.git
cd reveal.js
npm install
```

2. 将 PRESENTATION.md 内容转换为 reveal.js 格式

3. 启动服务：
```bash
npm start
```

---

### 方式 4: 手动制作 PowerPoint

根据 `PRESENTATION.md` 的内容，在 PowerPoint 或 Keynote 中手动制作。

#### 建议的 PPT 设计

**配色方案**：
- 主色：#FF6000（橙色）
- 辅助色：#1890FF（蓝色）
- 成功色：#52C41A（绿色）
- 警告色：#FAAD14（黄色）
- 错误色：#FF4D4F（红色）

**字体**：
- 标题：思源黑体 Bold / Arial Bold
- 正文：思源黑体 Regular / Arial Regular
- 代码：Fira Code / Consolas

**布局**：
- 标题页：居中大标题
- 内容页：左侧标题，右侧内容
- 图表页：上方标题，下方图表
- 总结页：要点列表

---

### 方式 5: 使用 Google Slides

1. 访问 https://slides.google.com
2. 创建新演示文稿
3. 根据 PRESENTATION.md 内容添加幻灯片
4. 使用 Google Slides 的模板和主题

---

### 方式 6: 使用 Canva

1. 访问 https://www.canva.com
2. 选择"演示文稿"模板
3. 根据 PRESENTATION.md 内容设计幻灯片
4. 导出为 PDF 或 PowerPoint

---

## 快速开始（推荐 Marp）

### 1. 安装 Marp

```bash
npm install -g @marp-team/marp-cli
```

### 2. 添加 Marp 配置

在 `PRESENTATION.md` 文件开头添加：

```markdown
---
marp: true
theme: default
paginate: true
backgroundColor: #fff
---
```

### 3. 生成 HTML

```bash
cd docs/solution
marp PRESENTATION.md -o PRESENTATION.html --html
```

### 4. 在浏览器中打开

```bash
open PRESENTATION.html  # macOS
```

---

## Marp 主题定制

创建 `marp-theme.css`：

```css
/* @theme sunbay */

@import 'default';

section {
  background-color: #fff;
  color: #262626;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}

h1 {
  color: #FF6000;
  border-bottom: 3px solid #FF6000;
  padding-bottom: 10px;
}

h2 {
  color: #1890FF;
}

code {
  background-color: #f5f5f5;
  padding: 2px 6px;
  border-radius: 3px;
  font-family: 'Fira Code', 'Consolas', monospace;
}

pre {
  background-color: #f5f5f5;
  padding: 15px;
  border-radius: 5px;
  border-left: 4px solid #FF6000;
}

table {
  border-collapse: collapse;
  width: 100%;
}

th {
  background-color: #FF6000;
  color: white;
  padding: 10px;
}

td {
  padding: 8px;
  border-bottom: 1px solid #f0f0f0;
}

strong {
  color: #FF6000;
}
```

使用自定义主题：

```bash
marp PRESENTATION.md --theme marp-theme.css -o PRESENTATION.html
```

---

## 演示技巧

### 1. 演讲时间分配（建议 30-45 分钟）

- 方案概述：3 分钟
- 系统架构：5 分钟
- 核心功能：10 分钟
- 安全保障：5 分钟
- 技术优势：5 分钟
- 项目成果：3 分钟
- 应用场景：5 分钟
- 商业价值：3 分钟
- Q&A：5-10 分钟

### 2. 演讲要点

- **开场**：简短介绍，吸引注意力
- **架构**：使用图表，清晰展示
- **功能**：结合实际案例，生动说明
- **安全**：强调金融级标准，建立信任
- **成果**：用数据说话，展示实力
- **场景**：针对听众，定制化说明
- **结尾**：总结要点，留下深刻印象

### 3. 互动建议

- 在关键页面停留，询问听众是否有问题
- 准备 Demo 视频或截图
- 准备常见问题的答案
- 准备技术细节的补充材料

---

## 导出格式对比

| 格式 | 优点 | 缺点 | 适用场景 |
|------|------|------|---------|
| **HTML** | 交互性强，动画效果好 | 需要浏览器 | 在线演示 |
| **PDF** | 通用性强，易分享 | 无动画效果 | 文档分发 |
| **PPTX** | 可编辑，兼容性好 | 格式可能丢失 | 需要修改 |
| **Markdown** | 易维护，版本控制 | 需要工具查看 | 开发团队 |

---

## 常见问题

### Q: Slidev 安装失败怎么办？

A: 使用 Marp 代替，更简单稳定：
```bash
npm install -g @marp-team/marp-cli
```

### Q: 如何添加公司 Logo？

A: 在 Marp 主题中添加：
```css
section::after {
  content: '';
  background-image: url('logo.png');
  background-size: contain;
  width: 100px;
  height: 50px;
  position: absolute;
  bottom: 20px;
  right: 20px;
}
```

### Q: 如何添加页码？

A: 在 PRESENTATION.md 开头添加：
```markdown
---
marp: true
paginate: true
---
```

### Q: 如何导出高质量 PDF？

A: 使用 Marp 的 PDF 导出：
```bash
marp PRESENTATION.md -o PRESENTATION.pdf --pdf-outlines
```

---

## 资源链接

- **Marp 官网**: https://marp.app/
- **Marp CLI 文档**: https://github.com/marp-team/marp-cli
- **reveal.js**: https://revealjs.com/
- **Slidev**: https://sli.dev/
- **Markdown 语法**: https://www.markdownguide.org/

---

## 下一步

1. 选择一种方式生成演示文稿
2. 根据实际需求调整内容
3. 添加公司 Logo 和品牌元素
4. 准备演讲稿和 Demo
5. 进行试讲和优化

---

**提示**: 如果需要快速预览，推荐使用 Marp 的实时预览功能：

```bash
npm install -g @marp-team/marp-cli
cd docs/solution
marp -s PRESENTATION.md
```

然后在浏览器中打开 http://localhost:8080 即可实时查看效果！
