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
