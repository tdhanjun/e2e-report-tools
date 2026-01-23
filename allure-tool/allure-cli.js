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
// Load Configuration
// ======================
require('dotenv').config({ path: path.join(__dirname, '../.env') });

// ======================
// Configuration
// ======================
const BASE_PORT = 8000;
const MAX_PORT = 8010;
const DEBUG = process.env.DEBUG === 'true';

// Read configuration from environment variables
const JAVA_HOME = process.env.JAVA_HOME;
const ALLURE_BIN = process.env.ALLURE_BIN;

// Configuration validation
if (!JAVA_HOME || !ALLURE_BIN) {
  console.error('[Allure CLI] ❌ Configuration missing!');
  console.error('[Allure CLI] Please run: npm run setup');
  process.exit(1);
}

// ======================
// Ensure logs directory exists
// ======================
const logsDir = path.join(__dirname, '../logs');
if (!fs.existsSync(logsDir)) {
  fs.mkdirSync(logsDir, { recursive: true });
}

// ======================
// Resolve real Allure path (bypass Homebrew wrapper)
// ======================
function getRealAllurePath() {
  let realPath = ALLURE_BIN;
  
  // If Allure is installed via Homebrew, extract the real path
  if (ALLURE_BIN.includes('/homebrew/bin/allure')) {
    try {
      const wrapperContent = fs.readFileSync(ALLURE_BIN, 'utf8');
      const match = wrapperContent.match(/"([^"]+libexec\/bin\/allure)"/);
      if (match) {
        realPath = match[1];
        if (DEBUG) {
          console.log(`[Allure CLI] [DEBUG] Resolved real allure path: ${realPath}`);
        }
      }
    } catch (e) {
      console.warn('[Allure CLI] [WARN] Could not extract real allure path, using configured path');
    }
  }
  
  return realPath;
}

const REAL_ALLURE_BIN = getRealAllurePath();

if (DEBUG) {
  console.log('[Allure CLI] [DEBUG] Configuration:');
  console.log(`[Allure CLI] [DEBUG]   JAVA_HOME: ${JAVA_HOME}`);
  console.log(`[Allure CLI] [DEBUG]   ALLURE_BIN: ${ALLURE_BIN}`);
  console.log(`[Allure CLI] [DEBUG]   REAL_ALLURE_BIN: ${REAL_ALLURE_BIN}`);
}
// ======================
// Global server reference
// ======================
let currentServer = null;

// ======================
// Utility Functions
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
    // Use system unzip command for better compatibility with various zip formats
    // especially when zip contains trace files or other special attachments
    try {
      if (DEBUG) {
        console.log(`[Allure CLI] [DEBUG] Using system unzip → ${filePath}`);
      }
      execSync(`unzip -q "${filePath}" -d "${targetFolder}"`, { stdio: 'inherit' });
    } catch (err) {
      // Fallback to unzipper library if system unzip fails
      console.log(`[Allure CLI] ⚠️ System unzip failed, trying unzipper library...`);
      await fs.createReadStream(filePath)
        .pipe(unzipper.Extract({ path: targetFolder }))
        .promise();
    }

    // Handle nested zip files (skip attachment files)
    const files = await fs.promises.readdir(targetFolder);
    for (const file of files) {
      if (file.endsWith(".zip")) {
        // Skip Allure attachment files (e.g., UUID-attachment.zip or trace.zip)
        if (file.includes("-attachment.zip") || file === "trace.zip") {
          if (DEBUG) {
            console.log(`[Allure CLI] [DEBUG] Skipping attachment file: ${file}`);
          }
          continue;
        }
        
        // Only unzip nested allure-results.zip or similar result archives
        if (file.toLowerCase().includes("allure-results")) {
          const nestedZip = path.join(targetFolder, file);
          console.log(`[Allure CLI] ⚡ Detected nested zip: ${file}, unzipping again...`);
          await unzipToFolder(nestedZip);
          await fs.promises.unlink(nestedZip);
        } else if (DEBUG) {
          console.log(`[Allure CLI] [DEBUG] Skipping non-results zip: ${file}`);
        }
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

  // Force disable cache
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
// Register Ctrl+C handler only once
// ======================
process.once("SIGINT", () => {
  console.log("\n[Allure CLI] Stopping server...");
  if (currentServer) currentServer.close(() => process.exit());
  else process.exit();
});

// ======================
// CLI Main Logic
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
    
    // ✅ Use pre-resolved real Allure path and pass correct JAVA_HOME
    execSync(
      `"${REAL_ALLURE_BIN}" generate "${resultsPath}" -o "${reportDir}" --clean`,
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

  // Ensure tracePath exists
  if (!tracePath || !fs.existsSync(tracePath)) {
    console.error(`[Allure CLI] ❌ Trace file not found: "${tracePath}"`);
    return;
  }

  console.log(`[Allure CLI] ⚡ Opening Playwright trace → ${tracePath}`);

  // Use spawn to open trace viewer
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
// Entry Point
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
const browser = args[2]; // Optional, defaults to chromium

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