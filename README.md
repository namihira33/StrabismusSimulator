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
