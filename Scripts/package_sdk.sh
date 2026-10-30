#!/bin/bash
# ============================================================
# package_sdk.sh — 打包 xcframework 为 zip 并计算 SPM checksum
#
# 存放路径: 每个 SDK 仓库根目录下的 Scripts/package_sdk.sh
# 用法: ./package_sdk.sh <SDK名称> <版本号>
# 示例: ./package_sdk.sh PPBaseKit 1.2.17
# ============================================================

set -e  # 任何命令失败立即退出

SDK_NAME="$1"
VERSION="$2"

# ---- 参数校验 ----
if [ -z "$SDK_NAME" ] || [ -z "$VERSION" ]; then
    echo "❌ 用法错误"
    echo "   用法: $0 <SDK名称> <版本号>"
    echo "   示例: $0 PPBaseKit 1.2.17"
    echo "   示例: $0 PPBluetoothKit 1.2.45"
    exit 1
fi

# ---- 路径定义 ----
# 脚本所在目录的上级目录（即仓库根目录）
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

XCFW_DIR="${SDK_NAME}.xcframework"
ZIP_NAME="${SDK_NAME}-${VERSION}.xcframework.zip"

# ---- 前置检查 ----
if [ ! -d "$XCFW_DIR" ]; then
    echo "❌ 找不到 xcframework 目录: $XCFW_DIR"
    echo "   请确认当前目录下存在 ${SDK_NAME}.xcframework/"
    exit 1
fi

if ! command -v ditto &> /dev/null; then
    echo "❌ ditto 命令不可用（需要 macOS 环境）"
    exit 1
fi

if ! command -v swift &> /dev/null; then
    echo "❌ swift 命令不可用（需要安装 Xcode Command Line Tools）"
    exit 1
fi

# ---- 执行打包 ----
echo "📦 开始打包..."
echo "   仓库目录: $REPO_ROOT"
echo "   xcframework: $XCFW_DIR"
echo "   输出 zip: $ZIP_NAME"
echo ""

# 如果已存在同名 zip，先删除（避免 ditto 追加）
if [ -f "$ZIP_NAME" ]; then
    echo "⚠️  已存在 $ZIP_NAME，将覆盖"
    rm "$ZIP_NAME"
fi

ditto -c -k --sequesterRsrc --keepParent "$XCFW_DIR" "$ZIP_NAME"

if [ ! -f "$ZIP_NAME" ]; then
    echo "❌ 打包失败，未生成 $ZIP_NAME"
    exit 1
fi

# 显示 zip 大小
ZIP_SIZE=$(du -h "$ZIP_NAME" | cut -f1)
echo "✅ 打包完成 (大小: $ZIP_SIZE)"

# ---- 计算 checksum ----
echo ""
echo "🔐 计算 SHA256 checksum..."
CHECKSUM=$(swift package compute-checksum "$ZIP_NAME")

# ---- 输出结果 ----
echo ""
echo "========================================="
echo "✅ 完成！"
echo "========================================="
echo ""
echo "📋 文件信息:"
echo "   zip 文件: $ZIP_NAME"
echo "   zip 路径: $REPO_ROOT/$ZIP_NAME"
echo "   SHA256:   $CHECKSUM"
echo ""
echo "📋 请填入 Package.swift 的 checksum 字段:"
echo "   checksum: \"$CHECKSUM\""
echo ""
echo "📋 下一步:"
echo "   1. 将 $ZIP_NAME 上传到 GitHub Release"
echo "   2. Release tag: $VERSION"
echo "   3. 确认 URL 可访问后，提交 Package.swift"
echo "========================================="