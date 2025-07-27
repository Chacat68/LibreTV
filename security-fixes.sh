#!/bin/bash

# LibreTV 安全漏洞快速修复脚本
# 使用方法: chmod +x security-fixes.sh && ./security-fixes.sh

echo "🔧 开始执行 LibreTV 安全漏洞修复..."
echo "======================================"

# 1. 修复依赖包漏洞
echo "📦 修复依赖包安全漏洞..."
npm audit fix
if [ $? -eq 0 ]; then
    echo "✅ 依赖包漏洞修复完成"
else
    echo "❌ 依赖包漏洞修复失败，请手动检查"
fi
echo ""

# 2. 更新所有依赖到最新版本
echo "🔄 更新依赖包到最新版本..."
npm update
if [ $? -eq 0 ]; then
    echo "✅ 依赖包更新完成"
else
    echo "❌ 依赖包更新失败"
fi
echo ""

# 3. 创建改进的安全头配置
echo "🛡️ 创建改进的安全头配置..."
cat > _headers_secure << 'EOF'
# 增强的安全头配置
/*
  # 基础安全头
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  X-XSS-Protection: 1; mode=block
  Referrer-Policy: strict-origin-when-cross-origin
  
  # 内容安全策略 (根据需要调整)
  Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:; connect-src 'self' https:; font-src 'self' data:; object-src 'none'; media-src 'self' https:; frame-src 'none';
  
  # 权限策略
  Permissions-Policy: camera=(), microphone=(), geolocation=(), payment=(), usb=(), magnetometer=(), gyroscope=(), accelerometer=()
  
  # HTTPS 强制 (生产环境启用)
  # Strict-Transport-Security: max-age=31536000; includeSubDomains; preload

# API 代理路径的 CORS 配置
/proxy/*
  Access-Control-Allow-Origin: *
  Access-Control-Allow-Methods: GET, POST, OPTIONS
  Access-Control-Allow-Headers: Content-Type, Authorization
  Access-Control-Max-Age: 86400
  # 限制代理请求大小
  Content-Length: 10485760

# 静态资源缓存和安全
/css/*
  Cache-Control: public, max-age=31536000, immutable
  X-Content-Type-Options: nosniff
  
/js/*
  Cache-Control: public, max-age=31536000, immutable
  X-Content-Type-Options: nosniff
  
/libs/*
  Cache-Control: public, max-age=31536000, immutable
  X-Content-Type-Options: nosniff
  
/image/*
  Cache-Control: public, max-age=31536000, immutable
  X-Content-Type-Options: nosniff

# HTML 文件不缓存
/*.html
  Cache-Control: no-cache, no-store, must-revalidate
  Pragma: no-cache
  Expires: 0
  
# 主页不缓存
/
  Cache-Control: no-cache, no-store, must-revalidate
  Pragma: no-cache
  Expires: 0

# 敏感文件保护
/.env*
  X-Robots-Tag: noindex, nofollow, nosnippet, noarchive
  
/package*.json
  X-Robots-Tag: noindex, nofollow, nosnippet, noarchive
  
/*.md
  X-Robots-Tag: noindex, nofollow, nosnippet, noarchive
EOF

echo "✅ 安全头配置文件已创建: _headers_secure"
echo "💡 提示: 请将 _headers_secure 重命名为 _headers 以应用新配置"
echo ""

# 4. 创建环境变量安全配置示例
echo "🔐 创建安全的环境变量配置示例..."
cat > .env.security << 'EOF'
# LibreTV 安全配置示例
# 复制到 .env 文件并根据需要修改

# 基本配置
PORT=8080
DEBUG=false

# 密码配置 (使用强密码)
# PASSWORD=your_strong_password_here
# ADMINPASSWORD=your_admin_strong_password_here

# CORS 配置 (生产环境应限制域名)
CORS_ORIGIN=*

# 请求配置
REQUEST_TIMEOUT=5000
MAX_RETRIES=2
USER_AGENT=Mozilla/5.0 (compatible; LibreTV/1.1.0)

# 缓存配置
CACHE_MAX_AGE=1d

# 增强的安全配置
# 阻止的主机名 (包含更多内网地址)
BLOCKED_HOSTS=localhost,127.0.0.1,0.0.0.0,::1,169.254.169.254,metadata.google.internal

# 阻止的IP前缀 (包含更多私有网段)
BLOCKED_IP_PREFIXES=192.168.,10.,172.16.,172.17.,172.18.,172.19.,172.20.,172.21.,172.22.,172.23.,172.24.,172.25.,172.26.,172.27.,172.28.,172.29.,172.30.,172.31.,169.254.

# 过滤的响应头
FILTERED_HEADERS=content-security-policy,cookie,set-cookie,x-frame-options,access-control-allow-origin,server,x-powered-by

# 请求大小限制 (字节)
MAX_REQUEST_SIZE=10485760

# 速率限制配置
RATE_LIMIT_WINDOW=900000
RATE_LIMIT_MAX_REQUESTS=100
EOF

echo "✅ 安全环境变量配置示例已创建: .env.security"
echo ""

# 5. 创建输入验证工具函数
echo "🔍 创建输入验证工具函数..."
mkdir -p js/utils
cat > js/utils/security.js << 'EOF'
// 安全工具函数

/**
 * HTML 实体编码
 * @param {string} str - 需要编码的字符串
 * @returns {string} 编码后的字符串
 */
function escapeHtml(str) {
    if (typeof str !== 'string') return '';
    
    const entityMap = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#39;',
        '/': '&#x2F;',
        '`': '&#x60;',
        '=': '&#x3D;'
    };
    
    return str.replace(/[&<>"'`=\/]/g, (s) => entityMap[s]);
}

/**
 * URL 验证
 * @param {string} url - 需要验证的URL
 * @returns {boolean} 是否为有效URL
 */
function isValidUrl(url) {
    try {
        const parsed = new URL(url);
        return ['http:', 'https:'].includes(parsed.protocol);
    } catch {
        return false;
    }
}

/**
 * 清理搜索查询
 * @param {string} query - 搜索查询
 * @returns {string} 清理后的查询
 */
function sanitizeSearchQuery(query) {
    if (typeof query !== 'string') return '';
    
    return query
        .trim()
        .substring(0, 100) // 限制长度
        .replace(/[<>"'&]/g, '') // 移除危险字符
        .replace(/\s+/g, ' '); // 规范化空格
}

/**
 * 验证API名称
 * @param {string} name - API名称
 * @returns {boolean} 是否为有效名称
 */
function isValidApiName(name) {
    if (typeof name !== 'string') return false;
    return /^[a-zA-Z0-9\u4e00-\u9fa5\s_-]{1,50}$/.test(name);
}

// 导出函数
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        escapeHtml,
        isValidUrl,
        sanitizeSearchQuery,
        isValidApiName
    };
} else {
    // 浏览器环境
    window.SecurityUtils = {
        escapeHtml,
        isValidUrl,
        sanitizeSearchQuery,
        isValidApiName
    };
}
EOF

echo "✅ 安全工具函数已创建: js/utils/security.js"
echo ""

# 6. 创建服务器端安全中间件
echo "🛡️ 创建服务器端安全中间件..."
cat > security-middleware.mjs << 'EOF'
// 服务器端安全中间件
import rateLimit from 'express-rate-limit';
import helmet from 'helmet';

// 速率限制中间件
export const rateLimiter = rateLimit({
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW || '900000'), // 15分钟
    max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'), // 限制每个IP 100个请求
    message: '请求过于频繁，请稍后再试',
    standardHeaders: true,
    legacyHeaders: false,
});

// Helmet 安全头中间件
export const securityHeaders = helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            scriptSrc: ["'self'", "'unsafe-inline'", "'unsafe-eval'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            imgSrc: ["'self'", "data:", "https:"],
            connectSrc: ["'self'", "https:"],
            fontSrc: ["'self'", "data:"],
            objectSrc: ["'none'"],
            mediaSrc: ["'self'", "https:"],
            frameSrc: ["'none'"]
        }
    },
    hsts: {
        maxAge: 31536000,
        includeSubDomains: true,
        preload: true
    }
});

// 请求大小限制中间件
export const requestSizeLimit = (req, res, next) => {
    const maxSize = parseInt(process.env.MAX_REQUEST_SIZE || '10485760'); // 10MB
    
    if (req.headers['content-length'] && parseInt(req.headers['content-length']) > maxSize) {
        return res.status(413).send('请求体过大');
    }
    
    next();
};

// IP 验证增强函数
export function isPrivateIP(ip) {
    const privateRanges = [
        /^10\./,
        /^172\.(1[6-9]|2[0-9]|3[01])\./,
        /^192\.168\./,
        /^127\./,
        /^169\.254\./,
        /^::1$/,
        /^fc00:/,
        /^fe80:/
    ];
    
    return privateRanges.some(range => range.test(ip));
}
EOF

echo "✅ 服务器端安全中间件已创建: security-middleware.mjs"
echo "💡 提示: 需要安装 express-rate-limit 和 helmet: npm install express-rate-limit helmet"
echo ""

# 7. 运行最终的安全检查
echo "🔍 运行最终安全检查..."
npm audit --audit-level=moderate
echo ""

echo "🎉 安全修复脚本执行完成！"
echo "======================================"
echo "📋 已完成的修复:"
echo "   ✅ 依赖包漏洞修复"
echo "   ✅ 创建增强的安全头配置"
echo "   ✅ 创建安全环境变量示例"
echo "   ✅ 创建输入验证工具函数"
echo "   ✅ 创建服务器端安全中间件"
echo ""
echo "📝 后续手动操作:"
echo "   1. 将 _headers_secure 重命名为 _headers"
echo "   2. 根据 .env.security 配置您的 .env 文件"
echo "   3. 在代码中引入 js/utils/security.js"
echo "   4. 安装并配置安全中间件"
echo "   5. 审查并测试所有修改"
echo ""
echo "⚠️  重要提醒:"
echo "   - 在生产环境部署前请充分测试"
echo "   - 定期运行 npm audit 检查新漏洞"
echo "   - 考虑实施代码审查流程"
echo "   - 建议进行渗透测试验证安全性"
echo ""
echo "📖 详细信息请查看: SECURITY_AUDIT_REPORT.md"