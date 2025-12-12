#!/bin/bash

# 通用工具函数

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

validate_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        log "错误: 文件不存在 - $file"
        return 1
    fi
    
    # 检查文件大小
    local size=$(stat -c%s "$file")
    if [ "$size" -gt 20971520 ]; then
        log "警告: 大文件检测 - $(($size/1024/1024))MB"
    fi
    
    return 0
}

generate_filename() {
    local input_file="$1"
    local output_format="$2"
    local counter="$3"
    
    local base_name=$(basename "$input_file" | sed 's/\.[^.]*$//')
    local suffix=$(printf "%02d" "$counter")
    
    echo "${base_name}_${suffix}${output_format}"
}

create_toc() {
    local input_file="$1"
    local output_dir="$2"
    
    # 根据文件类型生成目录
    local extension="${input_file##*.}"
    
    case $extension in
        pdf)
            pdftk "$input_file" dump_data output "$output_dir/toc.txt" 2>/dev/null
            ;;
        epub|chm)
            ebook-meta "$input_file" --get-opf > "$output_dir/toc.opf" 2>/dev/null
            ;;
        doc|docx)
            # 使用LibreOffice提取目录
            libreoffice --headless --convert-to html "$input_file" --outdir "$output_dir" 2>/dev/null
            ;;
    esac
}