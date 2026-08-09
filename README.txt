# 🚀 Antigravity IDE - Multi-Instance Generator for macOS

A lightweight, automated Bash utility designed for macOS to generate, run, and manage **100% isolated, independent instances** of the **Antigravity IDE** (VS Code / Electron based).

---

## 🎯 The Problem It Solves

By default, opening multiple windows of Antigravity IDE on macOS forces them to share the exact same configuration directory (`~/Library/Application Support/Antigravity`). This creates severe limitations:

* **Single Account Limit:** You cannot use different Google/Gemini AI accounts simultaneously.
* **Shared AI Quotas:** Exhausting your free or paid Gemini API tier in one project blocks all other open projects.
* **Overlapping MCP Configurations:** Custom tools, MCP (Model Context Protocol) servers, and plugin extensions overwrite each other globally.

---

## 💡 The Solution

This tool clones the base application directly into `/Applications` and injects **isolated launch flags**:

1. **`--user-data-dir`**: Keeps login sessions, project settings, and Google/Gemini AI accounts strictly separated.
2. **`--extensions-dir`**: Isolates installed plugins and MCP tools per instance.
3. **Native macOS Keychain Support**: Preserves macOS secure credential storage without triggering "Keychain Not Found" errors.
4. **Custom Dock Icons**: Allows you to assign distinct colors/icons to each app instance, keeping your macOS Dock organized.

---

## 📁 Repository Structure

```text
AntiGravityGerator/
├── NewInstance.command          # Interactive script to create a new isolated instance
├── DeleteInstance.command       # Selective utility to delete a specific instance
└── DeleteAllInstances.command   # Complete cleanup script to wipe all generated instances