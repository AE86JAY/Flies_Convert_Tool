#!/bin/bash

log "应用补丁文件..."

# 检查patches目录是否存在
if [ -d "patches" ]; then
    # 应用所有.patch文件
    for patch_file in patches/*.patch; do
        if [ -f "$patch_file" ]; then
            log "应用补丁: $(basename "$patch_file")"
            patch -p1 < "$patch_file"
        fi
    done
    
    # 执行所有.sh补丁脚本
    for script_file in patches/*.sh; do
        if [ -f "$script_file" ]; then
            log "执行补丁脚本: $(basename "$script_file")"
            chmod +x "$script_file"
            "./$script_file"
        fi
    done
fi

log "补丁应用完成"