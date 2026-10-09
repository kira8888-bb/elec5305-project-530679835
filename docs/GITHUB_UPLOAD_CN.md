# 上传到已有 GitHub 仓库

目标：https://github.com/kira8888-bb/elec5305-project-530679835

1. 解压文件包，进入 elec5305-project-530679835 文件夹。
2. 在 GitHub 仓库首页选择 Add file -> Upload files，上传该文件夹内的文件和子目录。
   不要额外套一层同名文件夹。GitHub 网页可能不接收隐藏的 .gitignore；建议用本地
   Git 或 GitHub Desktop 一起提交。保留仓库中原 proposal/PROJECT_PROPOSAL.md 作为旧版。
3. 新 README 会替换旧 README；修订稿另存为 proposal/Peinan_Gu_Feedback_Two.md
   和 output/pdf/Peinan_Gu_Feedback_Two.pdf。检查网页上目录和链接是否正确。
4. 在 MATLAB 中将当前文件夹设为仓库根目录，运行 setup_project、run_tests、run_demo。
5. Pages 发布：Settings -> Pages -> Build and deployment，Source 选择
   Deploy from a branch，Branch 选择 main，目录选择 /docs，然后 Save。
6. 在 Actions 查看 Pages build/deployment 是否成功。用未登录或无痕窗口打开：
   https://kira8888-bb.github.io/elec5305-project-530679835/
   点击 proposal 和代码链接逐个确认。不要仅凭 README 中写了网址就认定已部署。

GitHub 官方说明：https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site

代码包未包含 .github/workflows 自动发布配置：现有仓库使用上述分支发布即可。
本地准备文件不等于已更改线上仓库或 Pages 设置。
