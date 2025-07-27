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
