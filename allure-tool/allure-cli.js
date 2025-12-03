#!/usr/bin/env node
const fs = require("fs");
const path = require("path");
const { execSync } = require("child_process");
const unzipper = require("unzipper");
const tar = require('tar');
const net = require("net");
const express = require("express");
const open = require("open").default;
const { spawn } = require('child_process');

// ======================
// 加载配置
// ======================
require('dotenv').config({ path: path.join(__dirname, '../.env') });

// ======================
// 配置区
// ======================
const BASE_PORT = 8000;
const MAX_PORT = 8010;

// 从环境变量读取配置
const JAVA_HOME = process.env.JAVA_HOME;
const ALLURE_BIN = process.env.ALLURE_BIN;

// 配置检查
if (!JAVA_HOME || !ALLURE_BIN) {
  console.error('[Allure CLI] ❌ Configuration missing!');
  console.error('[Allure CLI] Please run: npm run setup');
  process.exit(1);
}
// ======================
// 全局 server 引用
// ======================
let currentServer = null;

// ======================
// 工具函数
// ======================
function timestamp() {
  const now = new Date();
  const pad = (n) => String(n).padStart(2, "0");
  return (
    now.getFullYear() +
    pad(now.getMonth() + 1) +
    pad(now.getDate()) +
    "T" +
    pad(now.getHours()) +
    pad(now.getMinutes()) +
    pad(now.getSeconds()) +
    String(now.getMilliseconds()).padStart(3, "0")
  );
}

async function unzipToFolder(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  const baseName = path.basename(filePath).replace(/\s+/g, "_").replace(/(\.zip|\.tar\.gz|\.tgz)$/i, "");
  const targetFolder = path.join(path.dirname(filePath), `${baseName}_${timestamp()}`);

  await fs.promises.mkdir(targetFolder, { recursive: true });

  if (filePath.endsWith('.zip')) {
    await fs.createReadStream(filePath)
      .pipe(unzipper.Extract({ path: targetFolder }))
      .promise();

    // 解嵌套 zip
    const files = await fs.promises.readdir(targetFolder);
    for (const file of files) {
      if (file.endsWith(".zip")) {
        const nestedZip = path.join(targetFolder, file);
        console.log(`[Allure CLI] ⚡ Detected nested zip: ${file}, unzipping again...`);
        await extractArchive(nestedZip);
        await fs.promises.unlink(nestedZip);
      }
    }

  } else if (filePath.endsWith('.tar.gz') || filePath.endsWith('.tgz')) {
    await tar.x({
      file: filePath,
      cwd: targetFolder
    });
  } else {
    throw new Error(`[Allure CLI] ❌ Unsupported archive type: ${filePath}`);
  }

  return targetFolder;
}

function findResultsFolder(baseFolder) {
  const entries = fs.readdirSync(baseFolder);

  for (const entry of entries) {
    const fullPath = path.join(baseFolder, entry);
    if (!fs.statSync(fullPath).isDirectory()) continue;

    if (entry.toLowerCase().startsWith("allure-results")) {
      return fullPath;
    }

    const nested = findResultsFolder(fullPath);
    if (nested) return nested;
  }

  return null;
}

async function findFreePort(start = BASE_PORT, end = MAX_PORT) {
  for (let port = start; port <= end; port++) {
    const isFree = await new Promise((resolve) => {
      const tester = net.createServer()
        .once('error', () => resolve(false))
        .once('listening', () => tester.once('close', () => resolve(true)).close())
        .listen(port);
    });
    if (isFree) return port;
  }
  throw new Error(`No free port found in range ${start}-${end}`);
}

// ======================
// Node Server
// ======================
async function serveReport(reportDir) {
  if (currentServer) {
    console.log("[Allure CLI] ⚠️ Server is already running, stopping previous server...");
    currentServer.close();
  }

  const port = await findFreePort();
  const app = express();

  // 强制禁用缓存
  app.use(express.static(reportDir, {
    setHeaders: (res, path) => {
      res.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, proxy-revalidate");
      res.setHeader("Pragma", "no-cache");
      res.setHeader("Expires", "0");
      res.setHeader("Surrogate-Control", "no-store");
    }
  }));

  currentServer = app.listen(port, () => {
    const url = `http://localhost:${port}`;
    console.log(`[Allure CLI] 🌐 Serving report on port ${port}...`);
    console.log(`[Allure CLI] 🚀 Report URL → ${url}?t=${Date.now()}`);
    open(`${url}?t=${Date.now()}`).catch(() => console.log('[Allure CLI] ❌ Failed to open browser.'));
  });
}

// ======================
// Ctrl+C 只注册一次
// ======================
process.once("SIGINT", () => {
  console.log("\n[Allure CLI] Stopping server...");
  if (currentServer) currentServer.close(() => process.exit());
  else process.exit();
});

// ======================
// CLI 主逻辑
// ======================
async function run(zipFile) {
  console.log(`[Allure CLI] 📦 Unzipping → ${zipFile}`);
  const folder = await unzipToFolder(zipFile);
  console.log(`[Allure CLI] 📁 Unzip completed: ${folder}`);

  const resultsPath = findResultsFolder(folder);
  if (!resultsPath) {
    console.error("❌ No allure-results folder found after unzipping");
    return;
  }
  console.log(`[Allure CLI] ⚡ Using resultsPath → ${resultsPath}`);

  const reportDir = path.join(folder, "report");
  try {
    console.log(`[Allure CLI] ⚡ Generating Allure report...`);
    // ✅ 修复 JAVA_HOME 环境，解决 libjli.dylib 找不到
    execSync(
      `"${ALLURE_BIN}" generate "${resultsPath}" -o "${reportDir}" --clean`,
      { stdio: "inherit", env: { ...process.env, JAVA_HOME } }
    );
    console.log(`[Allure CLI] ✅ Report generated: ${reportDir}`);

    await serveReport(reportDir);
  } catch (err) {
    console.error("[Allure CLI] ❌ Failed to generate report:", err.message);
  }
}

async function openReport(reportDir) {
  console.log(`[Allure CLI] 📂 Opening existing report → ${reportDir}`);
  await serveReport(reportDir);
}

async function openTrace(tracePath, browser = 'chromium') {
  console.log(`[Allure CLI] [DEBUG] Received tracePath: "${tracePath}"`);

  // 确保 tracePath 存在
  if (!tracePath || !fs.existsSync(tracePath)) {
    console.error(`[Allure CLI] ❌ Trace file not found: "${tracePath}"`);
    return;
  }

  console.log(`[Allure CLI] ⚡ Opening Playwright trace → ${tracePath}`);

  // 使用 spawn 打开 trace viewer
  const proc = spawn('npx', ['playwright', 'show-trace', tracePath], {
    stdio: 'inherit',
    env: { PATH: process.env.PATH }
  });

  proc.on('error', (err) => {
    console.error(`[Allure CLI] ❌ Failed to start trace viewer: ${err.message}`);
  });

  proc.on('exit', (code) => {
    console.log(`[Allure CLI] Trace viewer exited with code ${code}`);
  });
}

// ======================
// 入口
// ======================
const args = process.argv.slice(2);
if (args.length < 2) {
  console.log("Usage:");
  console.log("  node allure-cli.js run <allure-results.zip>");
  console.log("  node allure-cli.js open <report-folder>");
  console.log("  node allure-cli.js trace <data_attachments.zip>")
  process.exit(1);
}

const cmd = args[0];
const target = args[1];
const browser = args[2]; // 可选，默认 chromium

if (cmd === "run") {
  run(target);
} else if (cmd === "open") {
  openReport(target);
} else if (cmd === 'trace') {
  openTrace(target, browser || 'chromium');
}else {
  console.error("Unknown command:", cmd);
  process.exit(1);
}