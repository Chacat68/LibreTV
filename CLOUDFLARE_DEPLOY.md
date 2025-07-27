# Cloudflare Pages 部署指南

## 问题解决

您遇到的部署错误已经解决！错误的原因是缺少 `wrangler.toml` 配置文件。现在已经创建了正确的配置文件。

## 部署步骤

### 1. 登录 Cloudflare

```bash
npx wrangler login
```

这将打开浏览器，让您登录到 Cloudflare 账户。

### 2. 部署到 Cloudflare Pages

```bash
npm run deploy
```

或者直接使用：

```bash
npx wrangler pages deploy . --project-name=libretv
```

### 3. 本地预览（可选）

```bash
npm run preview
```

## 配置文件说明

### wrangler.toml
- 配置了项目名称和兼容性日期
- 设置了环境变量（DEBUG、CACHE_TTL 等）
- 配置为 Cloudflare Pages 项目

### _headers
- 配置了 CORS 头部
- 设置了静态资源缓存策略
- 添加了安全头部

### _redirects
- 处理代理路径重定向
- 配置搜索路径重定向
- SPA 路由回退

## 环境变量配置

在 Cloudflare Pages 控制台中，您可以设置以下环境变量：

- `PASSWORD`: 网站访问密码（可选）
- `ADMINPASSWORD`: 管理员密码（可选）
- `DEBUG`: 调试模式（默认 false）
- `CACHE_TTL`: 缓存时间（默认 86400 秒）
- `MAX_RECURSION`: 最大递归次数（默认 5）

## 遥测设置

Wrangler 的遥测功能已被禁用，以避免数据收集。如果您想重新启用，可以运行：

```bash
npx wrangler telemetry enable
```

## 故障排除

如果部署仍然失败，请检查：

1. 确保已登录 Cloudflare：`npx wrangler whoami`
2. 检查项目名称是否已存在
3. 确保所有必要文件都在项目根目录中

## 注意事项

- 这是一个 Cloudflare Pages 项目，支持静态文件和 Functions
- Functions 目录中的代码将作为 Cloudflare Workers 运行
- 项目配置为支持代理功能和环境变量注入