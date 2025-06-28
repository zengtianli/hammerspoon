#!/usr/bin/env python3
import os
import json
import time
import shutil
from pathlib import Path
from datetime import datetime
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
class BindingManager:
    def __init__(self):
        self.bindings_file = "file_bindings.json"
        self.bindings = self.load_bindings()
        self.trash_dir = Path(".binding_trash")
        self.trash_info = Path(".binding_trash/trash_info.json")
        self.deletion_history = {}
        # 创建回收站目录
        self.trash_dir.mkdir(exist_ok=True)
        self.load_deletion_history()
    def load_bindings(self):
        """加载文件绑定关系"""
        if os.path.exists(self.bindings_file):
            with open(self.bindings_file, 'r') as f:
                return json.load(f)
        return {}
    def save_bindings(self):
        """保存文件绑定关系"""
        with open(self.bindings_file, 'w') as f:
            json.dump(self.bindings, f, indent=2)
    def load_deletion_history(self):
        """加载删除历史"""
        if self.trash_info.exists():
            with open(self.trash_info, 'r') as f:
                self.deletion_history = json.load(f)
    def save_deletion_history(self):
        """保存删除历史"""
        with open(self.trash_info, 'w') as f:
            json.dump(self.deletion_history, f, indent=2)
    def create_binding(self, source, target):
        """创建文件绑定"""
        import shutil
        # 确保目标目录存在
        target.parent.mkdir(parents=True, exist_ok=True)
        # 处理文件名冲突
        if target.exists():
            base = target.stem
            ext = target.suffix
            counter = 1
            while target.exists():
                target = target.parent / f"{base}_{counter}{ext}"
                counter += 1
        shutil.copy2(source, target)
        # 记录双向绑定
        source_str = str(source.absolute())
        target_str = str(target.absolute())
        self.bindings[source_str] = target_str
        self.bindings[target_str] = source_str
        self.save_bindings()
        print(f"✓ 已绑定: {source.name} <-> {target.name}")
    def soft_delete(self, file_path):
        """软删除 - 移动到回收站而不是直接删除"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
        trash_subdir = self.trash_dir / timestamp
        trash_subdir.mkdir(exist_ok=True)
        # 保持原始路径结构
        relative_path = Path(file_path).relative_to(Path.cwd())
        trash_path = trash_subdir / relative_path
        trash_path.parent.mkdir(parents=True, exist_ok=True)
        # 移动文件到回收站
        shutil.move(str(file_path), str(trash_path))
        return timestamp, str(trash_path)
    def handle_deletion(self, deleted_file):
        """处理文件删除，软删除绑定的文件"""
        deleted_str = str(Path(deleted_file).absolute())
        if deleted_str in self.bindings:
            bound_file = self.bindings[deleted_str]
            # 创建删除记录
            deletion_id = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
            # 软删除绑定的文件
            if os.path.exists(bound_file):
                try:
                    timestamp, trash_path = self.soft_delete(bound_file)
                    # 记录删除信息
                    self.deletion_history[deletion_id] = {
                        'deleted_file': deleted_str,
                        'bound_file': bound_file,
                        'bound_trash_path': trash_path,
                        'timestamp': timestamp,
                        'time': datetime.now().isoformat()
                    }
                    self.save_deletion_history()
                    print(f"✓ 联动删除(已备份): {Path(bound_file).name}")
                    print(f"  备份ID: {deletion_id}")
                except Exception as e:
                    print(f"✗ 删除失败: {bound_file} - {e}")
            # 暂时保留绑定关系，以便恢复
            # 只在确认不需要恢复时才清理
    def handle_restoration(self, restored_file):
        """处理文件恢复 - 当检测到文件被恢复时，也恢复其绑定文件"""
        restored_str = str(Path(restored_file).absolute())
        # 查找最近的删除记录
        for deletion_id, info in sorted(self.deletion_history.items(), reverse=True):
            if info['deleted_file'] == restored_str:
                bound_trash_path = info['bound_trash_path']
                bound_original_path = info['bound_file']
                # 恢复绑定的文件
                if os.path.exists(bound_trash_path):
                    try:
                        # 确保目标目录存在
                        Path(bound_original_path).parent.mkdir(parents=True, exist_ok=True)
                        # 从回收站恢复文件
                        shutil.move(bound_trash_path, bound_original_path)
                        print(f"✓ 自动恢复绑定文件: {Path(bound_original_path).name}")
                        # 删除此恢复记录
                        del self.deletion_history[deletion_id]
                        self.save_deletion_history()
                        # 清理空的回收站目录
                        try:
                            Path(bound_trash_path).parent.rmdir()
                        except:
                            pass
                    except Exception as e:
                        print(f"✗ 恢复失败: {bound_original_path} - {e}")
                break
    def clean_trash(self, days=7):
        """清理超过指定天数的回收站文件"""
        from datetime import datetime, timedelta
        cutoff_date = datetime.now() - timedelta(days=days)
        for deletion_id, info in list(self.deletion_history.items()):
            deletion_time = datetime.fromisoformat(info['time'])
            if deletion_time < cutoff_date:
                # 删除回收站中的文件
                trash_path = Path(info['bound_trash_path'])
                if trash_path.exists():
                    trash_path.unlink()
                # 清理绑定关系
                deleted_file = info['deleted_file']
                bound_file = info['bound_file']
                if deleted_file in self.bindings:
                    del self.bindings[deleted_file]
                if bound_file in self.bindings:
                    del self.bindings[bound_file]
                # 删除记录
                del self.deletion_history[deletion_id]
        self.save_bindings()
        self.save_deletion_history()
class ImprovedDeletionHandler(FileSystemEventHandler):
    def __init__(self, binding_manager):
        self.binding_manager = binding_manager
        self.recently_deleted = set()  # 记录最近删除的文件
    def on_deleted(self, event):
        if not event.is_directory:
            print(f"\n检测到删除: {Path(event.src_path).name}")
            self.recently_deleted.add(event.src_path)
            self.binding_manager.handle_deletion(event.src_path)
    def on_created(self, event):
        """检测文件创建（可能是撤销删除）"""
        if not event.is_directory:
            file_path = event.src_path
            # 检查是否是最近删除的文件被恢复了
            if file_path in self.recently_deleted:
                print(f"\n检测到文件恢复: {Path(file_path).name}")
                self.recently_deleted.remove(file_path)
                self.binding_manager.handle_restoration(file_path)
def create_bound_files():
    """创建绑定文件"""
    manager = BindingManager()
    # 创建 alias_folder
    Path("alias_folder").mkdir(exist_ok=True)
    # 创建绑定
    for img_folder in Path(".").glob("*_img"):
        for file in img_folder.iterdir():
            if file.is_file():
                target = Path("alias_folder") / file.name
                manager.create_binding(file, target)
    for table_folder in Path(".").glob("*_tables"):
        for file in table_folder.iterdir():
            if file.is_file():
                target = Path("alias_folder") / file.name
                manager.create_binding(file, target)
    return manager
def start_monitoring():
    """启动文件监控"""
    manager = create_bound_files()
    # 设置监控
    event_handler = ImprovedDeletionHandler(manager)
    observer = Observer()
    # 监控所有相关目录
    observer.schedule(event_handler, ".", recursive=True)
    observer.start()
    print("\n文件绑定系统已启动（支持撤销恢复）")
    print("- 删除文件会自动删除绑定文件")
    print("- 撤销删除会自动恢复绑定文件")
    print("- 删除的文件会在 .binding_trash 中保留7天")
    print("\n按 Ctrl+C 退出\n")
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
        print("\n正在清理过期的回收站文件...")
        manager.clean_trash(days=7)
    observer.join()
# 添加手动恢复功能
def manual_restore(deletion_id=None):
    """手动恢复删除的文件"""
    manager = BindingManager()
    if not manager.deletion_history:
        print("没有可恢复的文件")
        return
    if deletion_id:
        # 恢复指定的删除
        if deletion_id in manager.deletion_history:
            info = manager.deletion_history[deletion_id]
            # 实现恢复逻辑...
    else:
        # 列出所有可恢复的删除
        print("\n可恢复的删除记录：")
        for did, info in sorted(manager.deletion_history.items(), reverse=True):
            print(f"\nID: {did}")
            print(f"时间: {info['time']}")
            print(f"删除的文件: {Path(info['deleted_file']).name}")
            print(f"绑定的文件: {Path(info['bound_file']).name}")
if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == "restore":
        manual_restore(sys.argv[2] if len(sys.argv) > 2 else None)
    else:
        start_monitoring()
