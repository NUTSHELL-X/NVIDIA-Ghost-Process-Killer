nv_smi_pids=($(nvidia-smi -q | awk '/Process ID/ {print $4}'))
fuser_pids=($(sudo fuser -v /dev/nvidia* 2>/dev/null | awk '/[0-9]+/'))

ghost_pids=()

for fuser_pid in "${fuser_pids[@]}"; do
    found=0
    for nv_smi_pid in "${nv_smi_pids[@]}"; do
        if [[ "$fuser_pid" == "$nv_smi_pid" ]]; then
            found=1
            break
        fi
    done
    if [[ "$found" -eq 0 ]]; then
        repeat_flag=0
        for ghost_pid in "${ghost_pids[@]}"; do
            if [[ "$ghost_pid" == "$fuser_pid" ]]; then
                repeat_flag=1
                break
            fi
        done
        if [[ "$repeat_flag" -eq 0 ]]; then
            ghost_pids+=("$fuser_pid")
        fi
    fi
done

echo "ghost pids:"
for pid in "${ghost_pids[@]}"; do
    kill "$pid"
    echo "ghost pid $pid killed"
done