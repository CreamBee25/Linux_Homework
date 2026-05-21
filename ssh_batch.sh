#!/bin/bash
# 批量SSH并发执行（原生并行，极速版）
# 并发数：建议10~50，根据你的机器性能调整
MAX_CONCURRENT=30

# 遍历所有IP
for i in {1..255}
do
    (
        ip="10.64.198.$i"
        log_num=$(( (i - 1) / 50 + 1 ))
        log_file="${log_num}.log"

        echo "✅ 处理 $ip → 日志: $log_file"
        # 并发执行SSH命令（超时5秒，非交互）
        ssh -o ConnectTimeout=5 -o BatchMode=yes root@"$ip" "hostname" >> "$log_file" 2>&1
    ) &

    # 控制最大并发数，避免进程爆炸
    if [[ $(jobs -r | wc -l) -ge $MAX_CONCURRENT ]]; then
        wait -n
    fi
done

# 等待所有后台进程执行完毕
wait
echo -e "\n🎉 全部执行完成！日志文件：1.log ~ 6.log"