-------- Japanese ver ----------
# 斜視シミュレータ - オープンソースハードウェアプラットフォーム

斜視患者向け単眼視線推定AIモデルの体系的評価のためのオープンソースハードウェアプラットフォーム

## 概要

本プロジェクトは、斜視患者特有の眼球運動条件下で単眼視線推定AIモデルを評価するための低コストオープンソース斜視シミュレータを提供します。正常両眼視を前提とした既存シミュレータとは異なり、本システムは斜視患者特有の非共役眼球運動を忠実に再現できます。

## 主な特徴

- **独立両眼制御**: 2つの独立制御可能な人工眼球
- **高精度**: ジャイロフィードバックによる0.1度以下の機械的精度
- **低コスト**: 総製作費約200ドル
- **オープンソース**: 完全なハードウェア設計とソフトウェアを公開
- **リアルタイムフィードバック**: 100HzでのMPU6050六軸ジャイロセンサ

## システム要件

### ハードウェア部品
- Arduino Nano マイクロコントローラ × 2
- MPU6050 六軸ジャイロセンサ × 2
- FS0307 サーボモータ × 4
- 人工眼球（Real Eye） × 2
- 3Dプリント材料（PLAフィラメント約300g）
- ブレッドボードと配線材料

### ソフトウェア要件
- Arduino IDE 1.8以上
- Python 3.7以上
- OpenCV 4.0以上

## インストール

### 1. ハードウェア組み立て
1. 提供されるSTLファイルを使用してすべての部品を3Dプリント
2. 2軸ジンバル機構を組み立て
3. サーボモータとジャイロセンサを取り付け
4. 配線図に従って回路を接続

### 2. ソフトウェアセットアップ
```bash
git clone https://github.com/namihira33/StrabismusSimulator.git
cd StrabismusSimulator
# 両方のマイクロコントローラにArduinoコードをアップロード
# Python依存関係をインストール
pip install -r requirements.txt
```

-------- English ver ----------

# Strabismus Simulator - Open Source Hardware Platform

An open-source hardware platform for systematic evaluation of monocular gaze estimation AI models under strabismus conditions.

## Overview

This project provides a low-cost, open-source strabismus simulator designed specifically for evaluating monocular gaze estimation AI models. Unlike existing simulators that assume normal binocular vision, our system can simulate the independent eye movements characteristic of strabismus patients.

## Key Features

- **Independent binocular control**: Two independently controllable artificial eyeballs
- **High precision**: Sub-0.1° mechanical accuracy with gyroscopic feedback
- **Low cost**: ~$250 USD total build cost
- **Open source**: Complete hardware designs and software available
- **Reproducible**: Identical random seeds ensure experimental reproducibility
- **Real-time feedback**: 6-axis gyroscopic sensors (MPU6050) at 100Hz

## System Requirements

### Hardware Components
- 2x Arduino Nano microcontrollers
- 2x MPU6050 6-axis gyroscopic sensors
- 4x FS0307 servo motors
- 2x Artificial eyeballs (Real Eye)
- 3D printing materials (PLA filament, ~300g)
- Breadboards and connecting wires

### Software Requirements
- Arduino IDE 1.8+
- Python 3.7+
- OpenCV 4.0+

## Installation

### 1. Hardware Assembly
1. 3D print all components using provided STL files
2. Assemble the dual-axis gimbal mechanism
3. Install servo motors and gyroscopic sensors
4. Connect circuits according to wiring diagrams

### 2. Software Setup
```bash
git clone https://github.com/namihira33/StrabismusSimulator.git
cd StrabismusSimulator
# Upload Arduino code to both microcontrollers
# Install Python dependencies
pip install -r requirements.txt
