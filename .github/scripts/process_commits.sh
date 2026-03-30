#!/bin/bash

# 主标题的 emoji 映射
process_commit() {
  local title="$1"
  case "$title" in
    feat:*|feature:*) echo "✨ ${title#*: }" ;; # 新功能
    fix:*) echo "🐛 ${title#*: }" ;; # 修复
    docs:*) echo "📝 ${title#*: }" ;; # 文档
    style:*) echo "💄 ${title#*: }" ;; # 样式
    refactor:*) echo "♻️ ${title#*: }" ;; # 重构
    perf:*) echo "⚡️ ${title#*: }" ;; # 性能
    test:*) echo "🧪 ${title#*: }" ;; # 测试
    build:*) echo "📦 ${title#*: }" ;; # 构建
    ci:*) echo "🎡 ${title#*: }" ;; # CI
    chore:*) echo "🔧 ${title#*: }" ;; # 杂项
    revert:*) echo "⏮️ ${title#*: }" ;; # 回退
    *) 
      case "$title" in
        Add*|Implement*) echo "✨ $title" ;; 
        Enhance*|Improve*) echo "🚀 $title" ;; 
        Update*) echo "⚡️ $title" ;; 
        Integrate*|Configure*) echo "🔌 $title" ;; 
        Fix*|Resolve*) echo "🐛 $title" ;; 
        Refactor*) echo "♻️ $title" ;; 
        Remove*|Delete*) echo "🔥 $title" ;; 
        Revert*) echo "⏮️ $title" ;; 
        *) echo "🔧 $title" ;; 
      esac
      ;;
  esac
}

# 处理详细信息
process_details() {
  local details=""
  local in_commit_body=false
  
  while IFS= read -r line; do
    if [[ $line == -* ]]; then
      # 处理列表项
      details+="$(process_detail "$line")\n"
    elif [[ $line =~ ^These[[:space:]]changes ]]; then
      # 处理总结行，保持原样并添加换行
      details+="     $line\n"
    elif [[ -n $line ]]; then
      # 处理其他非空行（比如列表项的延续行），保持缩进
      details+="     $line\n"
    else
      # 空行处理
      details+="\n"
    fi
  done
  
  printf '%b' "$details"
}

# 详细信息的 emoji 映射
process_detail() {
  local content="${1:2}" # 删除开头的 "- "
  local prefix="     - " # 修改缩进格式，保持列表形式
  
  # 1. 首先检查动词开头
  case "$content" in
    Replace*|Swap*|Change*) echo "${prefix}🔄 $content" && return ;;
    Increase*|Add*|Extend*) echo "${prefix}⬆️ $content" && return ;;
    Decrease*|Reduce*|Remove*) echo "${prefix}⬇️ $content" && return ;;
    Update*|Refresh*) echo "${prefix}🔁 $content" && return ;;
    Enhance*|Improve*) echo "${prefix}⚡️ $content" && return ;;
    Create*|Generate*) echo "${prefix}✨ $content" && return ;;
    Modify*|Adjust*) echo "${prefix}🔧 $content" && return ;;
    Fix*|Resolve*) echo "${prefix}🐛 $content" && return ;;
    Refactor*) echo "${prefix}♻️ $content" && return ;;
    Implement*) echo "${prefix}🎯 $content" && return ;;
    Integrate*) echo "${prefix}🔌 $content" && return ;;
    Ensure*|Verify*) echo "${prefix}✅ $content" && return ;;
    Develop*) echo "${prefix}🏗️ $content" && return ;;
  esac
  
  # 2. 检查特定功能/组件组合
  if [[ "$content" =~ (audio.*player|player.*audio) ]]; then
    echo "${prefix}🎵 $content" # 音频播放器特定
    return
  fi
  
  if [[ "$content" =~ (lyric.*overlay|overlay.*lyric) ]]; then
    echo "${prefix}📺 $content" # 歌词覆盖层特定
    return
  fi
  
  if [[ "$content" =~ (cache.*response|response.*cache) ]]; then
    echo "${prefix}💾 $content" # 响应缓存特定
    return
  fi
  
  if [[ "$content" =~ (error.*handling|handling.*error) ]]; then
    echo "${prefix}🛡️ $content" # 错误处理特定
    return
  fi
  
  # 3. 检查特定技术术语
  if [[ "$content" =~ dependency.injection ]]; then
    echo "${prefix}💉 $content" # 依赖注入
    return
  fi
  
  if [[ "$content" =~ state.management ]]; then
    echo "${prefix}📊 $content" # 状态管理
    return
  fi
  
  # 4. 检查具体内容类型
  case "$content" in
    *cache*|*Cache*|*storage*) 
      echo "${prefix}💾 $content" ;; # 缓存/存储相关
    *API*|*service*|*Service*|*request*) 
      echo "${prefix}🌐 $content" ;; # API/服务相关
    *UI*|*Screen*|*interface*|*layout*|*visual*|*theme*) 
      echo "${prefix}💫 $content" ;; # UI/布局/主题相关
    *audio*|*playback*|*media*) 
      echo "${prefix}🎵 $content" ;; # 音频相关
    *test*|*Test*) 
      echo "${prefix}🧪 $content" ;; # 测试相关
    *security*|*permission*|*auth*) 
      echo "${prefix}🔒 $content" ;; # 安全/权限相关
    *document*|*template*|*readability*) 
      echo "${prefix}📝 $content" ;; # 文档相关
    *component*|*widget*|*display*) 
      echo "${prefix}🎨 $content" ;; # 组件/显示相关
    *logic*|*handling*|*management*|*dependency*) 
      echo "${prefix}🧮 $content" ;; # 逻辑/处理/依赖相关
    *performance*|*efficiency*|*optimization*) 
      echo "${prefix}⚡️ $content" ;; # 性能相关
    *error*|*exception*|*handling*) 
      echo "${prefix}🛡️ $content" ;; # 错误处理相关
    *animation*|*transition*) 
      echo "${prefix}✨ $content" ;; # 动画相关
    *network*|*connectivity*) 
      echo "${prefix}📡 $content" ;; # 网络相关
    *data*|*model*|*entity*) 
      echo "${prefix}💽 $content" ;; # 数据模型相关
    *button*|*control*|*interaction*) 
      echo "${prefix}🎮 $content" ;; # 控件/交互相关
    *style*|*color*|*font*) 
      echo "${prefix}🎨 $content" ;; # 样式相关
    *) 
      echo "${prefix}📌 $content" ;; # 其他细节
  esac
}

# 主处理逻辑
current_commit=""
commit_details=""

while IFS= read -r line; do
  if [[ $line =~ ^[[:alpha:]] ]] && [[ ! $line =~ ^These[[:space:]]changes ]]; then
    # 如果有之前的 commit，先输出它
    if [ -n "$current_commit" ]; then
      if [ -n "$commit_details" ]; then
        printf "▶ %s\n" "$current_commit"
        printf '%b' "$commit_details" | process_details
        printf "\n"
      else
        printf "  %s\n" "$current_commit"
      fi
    fi
    current_commit=$(process_commit "$line")
    commit_details=""
  elif [[ $line == -* ]]; then
    commit_details+="$line\n"
  fi
done

# 输出最后一个 commit
if [ -n "$current_commit" ]; then
  if [ -n "$commit_details" ]; then
    printf "▶ %s\n" "$current_commit"
    printf '%b' "$commit_details" | process_details
  else
    printf "  %s\n" "$current_commit"
  fi
fi