from flask import Flask, request, abort
import subprocess
import hmac
import hashlib
import json
import logging
from datetime import datetime

app = Flask(__name__)

# 配置日志
logging.basicConfig(
    filename='/root/blog/webhook.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# 配置（需要与 GitHub WebHook 一致）
WEBHOOK_PATH = '/hexo-deploy'  # WebHook 路径
SECRET = 'myhexokey'  # 与 GitHub 配置的密钥相同
DEPLOY_SCRIPT_PATH = '/root/blog/deploy.sh'  # 部署脚本路径
TARGET_BRANCH = 'refs/heads/main'  # 监听的分支

def verify_signature(payload, signature, secret):
    """验证 GitHub 签名是否正确"""
    if not signature:
        return False
    # 提取签名哈希部分
    signature_hash = signature.split('=')[1] if '=' in signature else ''
    # 计算本地哈希
    h = hmac.new(secret.encode('utf-8'), payload, hashlib.sha256)
    local_hash = h.hexdigest()
    # 比较哈希（使用 hmac.compare_digest 防止时序攻击）
    return hmac.compare_digest(signature_hash, local_hash)

@app.route(WEBHOOK_PATH, methods=['POST'])
def handle_webhook():
    # 获取签名
    signature = request.headers.get('X-Hub-Signature-256')
    
    # 验证请求体和签名
    payload = request.get_data()
    if not verify_signature(payload, signature, SECRET):
        app.logger.warning('签名验证失败，拒绝处理请求')
        abort(403, description='签名验证失败')
    
    # 解析请求内容
    try:
        data = json.loads(payload)
    except json.JSONDecodeError:
        app.logger.error('无法解析请求体 JSON')
        abort(400, description='无效的 JSON 格式')
    
    # 检查是否是目标分支的推送
    if data.get('ref') != TARGET_BRANCH:
        app.logger.info(f'忽略非目标分支推送: {data.get("ref")}')
        return '忽略非目标分支推送', 200
    
    # 执行部署脚本
    app.logger.info('检测到目标分支推送，开始执行部署脚本...')
    try:
        # 执行部署脚本并捕获输出
        result = subprocess.run(
            ['bash', DEPLOY_SCRIPT_PATH],
            check=True,
            capture_output=True,
            text=True
        )
        app.logger.info(f'部署脚本执行成功: {result.stdout}')
        return '部署成功', 200
    except subprocess.CalledProcessError as e:
        app.logger.error(f'部署脚本执行失败: {e.stderr}')
        return '部署失败', 500

if __name__ == '__main__':
    # 启动服务，监听所有网络接口的 8080 端口
    app.run(host='0.0.0.0', port=8080)
    
