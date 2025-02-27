/// 与平台交互的操作

import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pikapika/basic/Common.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Method.dart';
import 'config/ChooserRoot.dart';

/// 复制内容到剪切板
void copyToClipBoard(BuildContext context, String string) {
  if (Platform.isWindows || Platform.isMacOS) {
    FlutterClipboard.copy(string);
    defaultToast(context, "已复制到剪切板");
  } else if (Platform.isAndroid) {
    FlutterClipboard.copy(string);
    defaultToast(context, "已复制到剪切板");
  }
}

/// 打开web页面
Future<dynamic> openUrl(String url) async {
  if (await canLaunch(url)) {
    await launch(
      url,
      forceSafariVC: false,
    );
  }
}

/// 保存图片
Future<dynamic> saveImage(String path, BuildContext context) async {
  Future? future;
  if (Platform.isIOS) {
    future = method.iosSaveFileToImage(path);
  } else if (Platform.isAndroid) {
    future = _saveImageAndroid(path, context);
  } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    String? folder = await chooseFolder(context);
    if (folder != null) {
      future = method.convertImageToJPEG100(path, folder);
    }
  } else {
    defaultToast(context, '暂不支持该平台');
    return;
  }
  if (future == null) {
    defaultToast(context, '保存取消');
    return;
  }
  try {
    await future;
    defaultToast(context, '保存成功');
  } catch (e, s) {
    print("$e\n$s");
    defaultToast(context, '保存失败');
  }
}

/// 保存图片且保持静默, 用于批量导出到相册
Future<dynamic> saveImageQuiet(String path, BuildContext context) async {
  if (Platform.isIOS) {
    return method.iosSaveFileToImage(path);
  } else if (Platform.isAndroid) {
    return _saveImageAndroid(path, context);
  } else {
    throw Exception("only mobile");
  }
}

Future<dynamic> _saveImageAndroid(String path, BuildContext context) async {
  var p = await Permission.storage.request();
  if (!p.isGranted) {
    return;
  }
  return method.androidSaveFileToImage(path);
}

/// 选择一个文件夹用于保存文件
Future<String?> chooseFolder(BuildContext context) async {
  return FilesystemPicker.open(
    title: '选择一个文件夹',
    pickText: '将文件保存到这里',
    context: context,
    fsType: FilesystemType.folder,
    rootDirectory: Directory(await currentChooserRoot()),
  );
}

/// 复制对话框
void confirmCopy(BuildContext context, String content) async {
  if (await confirmDialog(context, "复制", content)) {
    copyToClipBoard(context, content);
  }
}
