# OmaPhoto

OmaPhoto 是一款 Linux 分层图像编辑器，最初为 [Omarchy](https://omarchy.org) 桌面而作。本仓库（OmaPhoto-rh）是它的 RHEL 系发行版 fork：面向 RHEL、Rocky Linux 与 AlmaLinux 10 提供构建检查、RPM 打包、安装脚本与发布。软件本体与上游完全一致。

## 项目定位

- 上游项目：[OmaPhoto](https://github.com/ZacharyZhang-NY/OmaPhoto)。它是 [Compositor](https://github.com/robbietilton/Compositor)（Wonder Assembly 出品的 macOS 应用）的 Linux 移植，本仓库在其基础上只做 RHEL 平台的分发。
- 功能跟随上游：本 fork 不修改上游代码、不自行开发特性，上游的每个版本通过 rebase 整体获得；当前基于上游 v1.4.5。fork 的全部增量是 RHEL 分发物料（`scripts/install/rhel.sh`、`scripts/distro/rhel/`、`.github/workflows/release-rh.yml`）。
- Compositor 的源码即规格说明：OmaPhoto 保留它的工具、菜单与快捷键（Ctrl 对应 ⌘，Alt 对应 ⌥），并读写 Compositor 的 `.comp` 项目，项目可在两个应用之间往返。OmaPhoto 独立于 Wonder Assembly。
- 上游自有平台（Arch/Omarchy、Ubuntu、Fedora、NixOS）的打包、安装脚本与 CI 在本仓库原样保留，但由上游自行支持，本 fork 不对其作承诺、不测试、不分发。
- 感谢上游 OmaPhoto 的作者，以及 Compositor 的原作者。
- 问题反馈：安装、打包与 RHEL 平台适配问题请提本仓库的 issue；软件功能与上游 bug 请到上游仓库反馈。

## 功能

- 图层、图层组、蒙版、剪贴蒙版、混合模式与不透明度；整个图层可跨项目复制；Ungroup Layers（取消编组）
- 选区：marquee（选框）、lasso（套索）、magic wand（魔棒）及其对象模式（object mode）、Select › Subject、Select › Color Range、从图层载入选区、羽化（feather）、扩展与收缩（expand / contract）
- 画笔、橡皮、spot healing（污点修复）、clone stamp（仿制图章）、smudge（涂抹）、blur（模糊）、liquify（液化）、渐变、形状，以及文字工具（可对选中的字母单独设置颜色与字体）
- 移动、变换与扭曲图层和选区；标尺、参考线、可自行设置的网格，以及对图层、选区与形状的吸附
- Levels、Curves、Hue/Saturation、Exposure、Black & White、Color Balance、Gradient Map、Grain、Invert、模糊与噪点，既可作为一次性编辑，也可作为调整图层
- Camera Raw Filter，停靠在画布旁边，内含 Photoshop 同款曲线
- 图层效果：描边（stroke）、投影（drop shadow）、外发光与内发光（outer / inner glow）、颜色叠加（color overlay）、内阴影（inner shadow）
- 滤镜：高斯模糊与动感模糊、噪点、镜头校正、Vignette（晕影）、Bloom / Glow、Tonal Contrast、Dither（抖动）、Content-Aware Fill（内容识别填充）与 Remove Background（移除背景；U²-Net 模型经 ONNX Runtime 本地离线运行）
- 裁剪、修整（trim）、画布大小与图像大小；PNG 与 JPEG 导出（带可缩放预览）；新建画布预设（屏幕与社交媒体常用尺寸）
- 导入 JPEG、PNG、TIFF、HEIC、SVG、Photoshop 文件（PSD 与 PSB）与相机 RAW
- Open Recent（最近打开）与 Keyboard Shortcuts（键盘快捷键）窗口
- 拖动数值的标签即可滑动调值
- 项目保存期间可以继续工作
- 项目标签页可拖动排序；放不下的标签收进一个菜单
- 被其它程序在磁盘上改动的项目会就地重载；未保存的修改绝不未经询问就被替换

[验收运行](docs/acceptance.md)在应用自己的窗口里逐项核对上述功能，并附截图。

### 配合 AI 代理使用

AI 代理和脚本可以直接构建与编辑项目：一个 `.comp` 项目就是一个装着 PNG 图层和清单文件的文件夹，打开着的项目会随写入实时更新。见[编写 OmaPhoto 项目](docs/writing-comp-files.md)与[项目格式](docs/project-format.md)。

## 安装

支持的系统：RHEL、Rocky Linux、AlmaLinux 或 CentOS Stream 10，架构 x86_64。安装包内已捆绑 ONNX Runtime 与 Remove Background 所需的模型（因此下载体积约 200 MB），装完无需任何额外配置。

一键安装（下载脚本并运行；脚本会确认系统与架构，从本仓库 Releases 下载最新的 RPM，核对 SHA-256 后用 dnf 安装）：

```sh
curl -fsSLO https://raw.githubusercontent.com/aiyaoooo14/OmaPhoto-rh/main/scripts/install/rhel.sh && bash rhel.sh
```

EL9（RHEL / Rocky / Alma 9）暂未适配：脚本会明确提示，不会静默装出不匹配的包。

也可以手动下载安装：

```sh
curl -fsSLO https://github.com/aiyaoooo14/OmaPhoto-rh/releases/latest/download/omaphoto-el10.x86_64.rpm
curl -fsSLO https://github.com/aiyaoooo14/OmaPhoto-rh/releases/latest/download/SHA256SUMS
sha256sum -c --ignore-missing SHA256SUMS
sudo dnf install ./omaphoto-el10.x86_64.rpm
```

`releases/latest/download/…` 始终指向最新一次发布。安装包按 RHEL 10 的 x86-64-v3 基线编译，不含 AVX2 指令集的较老 CPU 无法运行。

### 可选：启用 HEIC 导入

EL 系仓库自带的 libheif 不含 HEVC 解码器（专利限制），因此默认无法导入 HEIC 照片；其余功能不受影响。需要导入 HEIC 时，先启用 [RPM Fusion free](https://rpmfusion.org/Configuration) 仓库，再安装：

```sh
sudo dnf install libheif-freeworld
```

已知包装缺陷：受构建工具链问题（CPack 对 rpm 弱依赖标签的探测误判）影响，安装包暂未携带 `libheif-freeworld` 的弱依赖（Suggests）标记。这不影响安装与任何功能使用；一键安装脚本会独立给出 HEIC 提示。

## 从源码构建

以下依赖在 Rocky Linux 10 上实测。先启用 EPEL 与 CRB 仓库：

```sh
sudo dnf install epel-release
sudo crb enable
```

安装编译工具与库：

```sh
sudo dnf install gcc gcc-c++ cmake ninja-build \
  qt6-qtbase-devel qt6-qtsvg-devel qt6-qtimageformats-devel \
  libheif-devel libraw-devel fontconfig-devel \
  shared-mime-info hicolor-icon-theme
```

EL10 仓库的 Qt 6.10 满足上游的 Qt 6.4 下限；libheif-devel 与 libraw-devel（提供 libraw_r）来自 EPEL。

ONNX Runtime 与 U²-Net 模型不在 EL 系仓库中，需要按上游 `Dockerfile.dev` 所用的同一版本自行准备；下载地址与 SHA-256 校验和以仓库内 `scripts/distro/rhel/Dockerfile` 为准：

- ONNX Runtime 1.21.0：解压后不必装入系统目录，configure 时用 `-Donnxruntime_DIR=<解压目录>/lib/cmake/onnxruntime` 指定即可。
- U²-Net 模型 `u2net.onnx`：configure 时用 `-DOMAPHOTO_MODEL=/path/to/u2net.onnx` 指定，`cmake --install` 会把它装成 `share/omaphoto/u2net.onnx`（Remove Background 功能必需）。

构建与运行：

```sh
cmake -S . -B build-rh -G Ninja
cmake --build build-rh
./build-rh/omaphoto
```

完整测试套件（无显示环境时在命令前加 `QT_QPA_PLATFORM=offscreen`）：

```sh
ctest --test-dir build-rh
```

上游另有一条基于 Docker 的构建路径（`scripts/dev.sh`，Ubuntu 24.04 容器），面向跨平台开发者，见上游仓库的说明。

## 许可证

MIT，与 Compositor 相同；见 `LICENSE`。Remove Background 通过 ONNX Runtime（MIT）运行 U²-Net 模型（Apache-2.0，`licenses/U-2-Net.txt`）。每个安装包都随附 ONNX Runtime 及其声明文件。
