name: Update Submodule and Build

on:
  workflow_dispatch:

jobs:
  update-and-build:
    runs-on: windows-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      with:
        submodules: false  # 先不下载子模块

    - name: Update submodule to latest from fork
      run: |
        # 删除旧的子模块内容
        rm -rf libs/hbb_common
        
        # 从你的 fork 重新克隆子模块
        git clone https://github.com/284445233/hbb_common.git libs/hbb_common
        
        # 配置子模块使用你的 fork
        git submodule init
        git config -f .gitmodules submodule.libs/hbb_common.url https://github.com/284445233/hbb_common.git
        git submodule sync
        
        # 提交这个更改
        git add .
        git config user.name "GitHub Actions"
        git config user.email "actions@github.com"
        git commit -m "Update hbb_common submodule to latest from fork" || echo "No changes to commit"
        git push || echo "Nothing to push"

    - name: Install Rust
      uses: actions-rust-lang/setup-rust-toolchain@v1

    - name: Build RustDesk
      run: cargo build --release --bin rustdesk

    - name: Upload EXE
      uses: actions/upload-artifact@v4
      with:
        name: rustdesk-updated
        path: target/release/rustdesk.exe
