#!/bin/bash

source scripts/utils.sh

log "开始分割文件..."

split_counter=1
for input_file in 转换后/*.*; do
    if [ ! -f "$input_file" ]; then
        continue
    fi
    
    # 获取文件大小（MB）
    file_size=$(stat -c%s "$input_file")
    file_size_mb=$((file_size / 1024 / 1024))
    
    # 如果文件大于20MB，则分割
    if [ "$file_size_mb" -gt 20 ]; then
        log "分割大文件: $input_file (${file_size_mb}MB)"
        
        # 根据文件类型选择分割方式
        case "${input_file##*.}" in
            pdf)
                # 分割PDF文件
                pdftk "$input_file" burst output "转换后/$(basename "${input_file%.*}")_%03d.pdf"
                rm "$input_file"
                ;;
                
            txt|html)
                # 按行数分割文本文件
                split -l 1000 "$input_file" "转换后/$(basename "${input_file%.*}")_"
                rm "$input_file"
                ;;
                
            *)
                # 默认按大小分割
                split -b 20M "$input_file" "转换后/$(basename "${input_file%.*}")_"
                rm "$input_file"
                ;;
        esac
    fi
done

log "文件分割完成"