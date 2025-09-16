#!/bin/bash

# 定义日志文件，方便排查问题
LOG_FILE="/root/blog/deploy.log"
echo "===== $(date "+%Y-%m-%d %H:%M:%S") 开始部署 =====" >> $LOG_FILE

# 进入博客目录
cd /root/blog || {
  echo "错误：无法进入/root/blog目录" >> $LOG_FILE
  exit 1
}

# 拉取最新代码
echo "拉取最新代码..." >> $LOG_FILE
git pull origin main >> $LOG_FILE 2>&1
if [ $? -ne 0 ]; then
  echo "错误：git pull失败" >> $LOG_FILE
  exit 1
fi

# 清理旧静态文件
echo "清理旧静态文件..." >> $LOG_FILE  # 新增：日志记录清理操作
hexo clean >> $LOG_FILE 2>&1            # 新增：执行hexo clean命令
if [ $? -ne 0 ]; then                   # 新增：检查清理操作是否成功
  echo "错误：hexo clean失败" >> $LOG_FILE
  exit 1
fi

# 生成静态文件（保持原hexo g的功能，此处hexo generate等价于hexo g）
echo "生成Hexo静态文件..." >> $LOG_FILE
hexo generate >> $LOG_FILE 2>&1
if [ $? -ne 0 ]; then
  echo "错误：hexo generate失败" >> $LOG_FILE
  exit 1
fi

# 停止现有Hexo服务（如果存在）
echo "停止现有Hexo服务..." >> $LOG_FILE
pkill -f "hexo server" >> $LOG_FILE 2>&1

# 启动Hexo服务（保持原hexo s的功能，此处hexo server等价于hexo s）
echo "启动Hexo服务..." >> $LOG_FILE
nohup hexo server > /dev/null 2>&1 &

echo "===== $(date "+%Y-%m-%d %H:%M:%S") 部署完成 =====" >> $LOG_FILE
